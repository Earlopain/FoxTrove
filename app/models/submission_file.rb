# frozen_string_literal: true

class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_many :e6_posts, dependent: :destroy

  validate :original_present

  after_destroy_commit :remove_from_iqdb
  after_save_commit :update_variants_and_iqdb
  # This adds framework after_commit hooks which must run after
  # the ones above for attachment_changes to work correctly
  has_one_attached :original
  has_one_attached :sample

  scope :with_attached, -> { with_attached_sample.with_attached_original }
  scope :with_everything, -> { with_attached.includes(:e6_posts, artist_submission: :artist_url) }

  scope :larger_iqdb_filesize_kb_exists, ->(treshold) { select_from_e6_posts_where_exists("size - ? > post_size and not post_is_deleted", treshold) }
  scope :larger_iqdb_filesize_percentage_exists, ->(treshold) { select_from_e6_posts_where_exists("size - (size / 100 * ?) > post_size and not post_is_deleted", treshold) }
  scope :smaller_iqdb_filesize_doesnt_exist, -> { select_from_e6_posts_where_not_exists("size <= post_size") }
  scope :larger_only_filesize_kb, ->(treshold) { larger_iqdb_filesize_kb_exists(treshold).smaller_iqdb_filesize_doesnt_exist.exact_match_doesnt_exist }
  scope :larger_only_filesize_percentage, ->(treshold) { larger_iqdb_filesize_percentage_exists(treshold).smaller_iqdb_filesize_doesnt_exist.exact_match_doesnt_exist }

  scope :larger_iqdb_dimensions_exist, -> { select_from_e6_posts_where_exists("width > post_width and height > post_height and not post_is_deleted") }
  scope :smaller_iqdb_dimensions_dont_exist, -> { select_from_e6_posts_where_not_exists("width <= post_width and height <= post_height") }
  scope :larger_only_dimensions, -> { larger_iqdb_dimensions_exist.smaller_iqdb_dimensions_dont_exist }

  scope :already_uploaded, -> { select_from_e6_posts_where_exists }
  scope :not_uploaded, -> { select_from_e6_posts_where_not_exists }
  scope :exact_match_exists, -> { select_from_e6_posts_where_exists("is_exact_match") }
  scope :exact_match_doesnt_exist, -> { select_from_e6_posts_where_not_exists("is_exact_match") }

  # avoid_posting and conditional_dnp never appear alone
  NON_ARTIST_TAGS = %w[unknown_artist unknown_artist_signature sound_warning epilepsy_warning].freeze

  scope :zero_sources, -> { joins(:e6_posts).where(e6_posts: { post_is_deleted: false }).where("jsonb_array_length(post_json->'sources') = 0") }
  scope :zero_artists, -> {
    artists_path = "post_json->'tags'->'artist'"
    artists_count = "jsonb_array_length(#{artists_path})"
    joins(:e6_posts).where(e6_posts: { post_is_deleted: false }).where("#{artists_count} = 0 or (#{artists_count} = 1 and #{artists_path}->>0 in (?))", NON_ARTIST_TAGS)
  }

  delegate :artist_url, :artist, to: :artist_submission

  def self.select_from_e6_posts_where_exists(condition = nil, *args)
    where("exists (#{select_from_e6_posts(condition)})", args)
  end

  def self.select_from_e6_posts_where_not_exists(condition = nil, *args)
    where("not exists (#{select_from_e6_posts(condition)})", args)
  end

  def self.select_from_e6_posts(condition)
    "select from e6_posts where submission_files.id = e6_posts.submission_file_id #{"and #{condition}" if condition}"
  end

  def self.from_attachable(attachable:, artist_submission:, url:, created_at:, file_identifier:)
    submission_file = SubmissionFile.new(
      artist_submission: artist_submission,
      direct_url: url,
      created_at_on_site: created_at,
      file_identifier: file_identifier,
    )
    case attachable
    when Tempfile
      submission_file.attach_original_from_file!(attachable)
    when ActiveStorage::Blob
      submission_file.attach_original_from_blob!(attachable)
    else
      raise ArgumentError, "'#{attachable.class}' is not supported"
    end
  end

  def attach_original_from_file!(file)
    # Deviantart doesn't have to return only images.
    # No way to find this out through the api response as far as I'm aware.
    # https://www.deviantart.com/fr95/art/779625010/
    mime_type = Marcel::MimeType.for file
    return if mime_type.in? Scraper::Submission::MIME_IGNORE

    filename = File.basename(Addressable::URI.parse(direct_url).path)
    blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)
    begin
      attach_original_from_blob!(blob)
    rescue StandardError => e
      blob.purge
      raise e
    end
  end

  def attach_original_from_blob!(blob)
    blob.analyze
    raise StandardError, "Failed to analyze" if blob.content_type == "application/octet-stream"
    raise StandardError, "'#{blob.content_type}' is not allowed" if blob.content_type.in? Scraper::Submission::MIME_IGNORE

    self.width = blob.metadata[:width]
    self.height = blob.metadata[:height]
    self.content_type = blob.content_type
    self.size = blob.byte_size

    if can_iqdb?
      begin
        Vips::Image.new_from_file(blob.service.path_for(blob.key), fail: true).stats
      rescue Vips::Error => e
        self.file_error = e.message.strip
      end
    end

    original.attach(blob)
    save!
  end

  def corrupt?
    file_error.present?
  end

  def original_present
    errors.add(:original_file, "not attached") unless original.attached?
  end

  def sample_generated?
    original.analyzed? && sample&.attached?
  end

  def md5
    Base64.decode64(original.checksum).unpack1("H*")
  end

  def can_iqdb?
    IqdbProxy.can_iqdb?(content_type)
  end

  def update_variants_and_iqdb
    return if attachment_changes["original"].blank?

    SubmissionFileUpdateJob.perform_later(self)
  end

  def update_e6_posts(priority: E6IqdbQueryJob::PRIORITIES[:manual_action])
    e6_posts.destroy_all
    similar = IqdbProxy.query_submission_file(self).pluck(:submission_file)
    similar.each { |s| s.e6_posts.destroy_all }

    E6IqdbQueryJob.set(priority: priority).perform_later(self)
    similar.each do |s|
      # Process matches from other artists after everything else.
      # Chances are that they're just wrong iqdb matches.
      priority_for_similar = s.artist_submission.artist == artist_submission.artist ? priority : priority - 50
      E6IqdbQueryJob.set(priority: priority_for_similar).perform_later(s)
    end
  end

  def update_e6_posts!
    e6_posts.destroy_all

    sample.open do |file|
      # FIXME: Error handling
      json = E6ApiClient.iqdb_query(file)
      break unless json.is_a? Array

      json.each do |entry|
        post_id = entry["post"]["posts"]["id"]
        post_json = E6ApiClient.get_post(post_id)
        post_entry = e6_posts.create(
          post_id: post_json["id"],
          post_width: post_json["file"]["width"],
          post_height: post_json["file"]["height"],
          post_size: post_json["file"]["size"],
          post_is_deleted: post_json["flags"]["deleted"],
          post_json: post_json,
          similarity_score: entry["score"],
          is_exact_match: md5 == post_json["file"]["md5"] || existing_matches(post_json["id"], is_exact_match: true).any?,
        )

        # Check if there are entries which were previously added
        # that are an exact visual match to this newly added exact match
        if post_entry.is_exact_match
          existing_matches(post_json["id"], is_exact_match: false).find_each do |existing_match|
            existing_match.update(is_exact_match: true)
          end
        end
      end
    end
  end

  def existing_matches(post_id, is_exact_match:)
    E6Post.joins(:submission_file)
      .where(post_id: post_id, submission_file: { iqdb_hash: iqdb_hash }, is_exact_match: is_exact_match)
  end

  def remove_from_iqdb
    IqdbProxy.remove_submission self if can_iqdb?
  end

  def generate_variants
    io = VariantGenerator.sample(file_path_for(:original), content_type)
    sample.attach(io: io, filename: "sample")
  end

  def file_path_for(variant)
    send(variant).service.path_for(send(variant).key)
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = status_search(params)
        q = q.zero_sources if params[:zero_sources] == "1"
        q = q.zero_artists if params[:zero_artists] == "1"
        q = q.attribute_matches(params[:content_type], :content_type)
        q = q.attribute_nil_check(params[:in_backlog], :added_to_backlog_at)
        q = q.attribute_nil_check(params[:hidden_from_search] || false, :hidden_from_search_at)
        q = q.attribute_nil_check(params[:corrupt], :file_error)
        q = q.join_attribute_matches(params[:title], artist_submission: :title_on_site)
        q = q.join_attribute_matches(params[:description], artist_submission: :description_on_site)
        q = q.join_attribute_matches(params[:artist_url_id], artist_submission: { artist_url: :id })
        q = q.join_attribute_matches(params[:artist_id], artist_submission: { artist_url: { artist: :id } })
        q = q.join_attribute_matches(params[:site_type], artist_submission: { artist_url: :site_type })
        q.order(created_at_on_site: :desc, file_identifier: :desc)
      end

      def status_search(params)
        if params[:upload_status].present?
          case params[:upload_status]
          when "larger_only_filesize_kb"
            size = (params[:larger_only_filesize_treshold] || 50).to_i.kilobytes
            send(params[:upload_status], size)
          when "larger_only_filesize_percentage"
            size = (params[:larger_only_filesize_treshold] || 10).to_i
            send(params[:upload_status], size)
          when "larger_only_dimensions", "exact_match_exists", "already_uploaded", "not_uploaded"
            send(params[:upload_status])
          else
            none
          end
        else
          all
        end
      end

      def search_params
        [:artist_id, :site_type, :upload_status, :corrupt, :zero_sources, :zero_artists, :larger_only_filesize_treshold, :content_type, :title, :description, { artist_url_id: [] }]
      end
    end
  end
end
