# frozen_string_literal: true

class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_one_attached :original
  has_one_attached :sample
  has_many :e6_iqdb_entries, class_name: "E6IqdbData", dependent: :destroy

  validate :original_present

  after_destroy_commit :remove_from_iqdb
  after_save_commit :update_variants_and_iqdb

  scope :with_attached, -> { with_attached_sample.with_attached_original }
  scope :with_everything, -> { with_attached.includes(:e6_iqdb_entries, artist_submission: :artist_url) }

  scope :larger_iqdb_filesize_kb_exists, ->(treshold) { select_from_e6_iqdb_data_where_exists("size - ? > post_size and not post_is_deleted", treshold) }
  scope :larger_iqdb_filesize_percentage_exists, ->(treshold) { select_from_e6_iqdb_data_where_exists("size - (size / 100 * ?) > post_size and not post_is_deleted", treshold) }
  scope :smaller_iqdb_filesize_doesnt_exist, -> { select_from_e6_iqdb_data_where_not_exists("size <= post_size") }
  scope :larger_only_filesize_kb, ->(treshold) { larger_iqdb_filesize_kb_exists(treshold).smaller_iqdb_filesize_doesnt_exist.exact_match_doesnt_exist }
  scope :larger_only_filesize_percentage, ->(treshold) { larger_iqdb_filesize_percentage_exists(treshold).smaller_iqdb_filesize_doesnt_exist.exact_match_doesnt_exist }

  scope :larger_iqdb_dimensions_exist, -> { select_from_e6_iqdb_data_where_exists("width > post_width and height > post_height and not post_is_deleted") }
  scope :smaller_iqdb_dimensions_dont_exist, -> { select_from_e6_iqdb_data_where_not_exists("width <= post_width and height <= post_height") }
  scope :larger_only_dimensions, -> { larger_iqdb_dimensions_exist.smaller_iqdb_dimensions_dont_exist }

  scope :already_uploaded, -> { select_from_e6_iqdb_data_where_exists }
  scope :not_uploaded, -> { select_from_e6_iqdb_data_where_not_exists }
  scope :exact_match_exists, -> { select_from_e6_iqdb_data_where_exists("is_exact_match") }
  scope :exact_match_doesnt_exist, -> { select_from_e6_iqdb_data_where_not_exists("is_exact_match") }

  delegate :artist_url, :artist, to: :artist_submission

  def self.select_from_e6_iqdb_data_where_exists(condition = nil, *args)
    where("exists (#{select_from_e6_iqdb_data(condition)})", args)
  end

  def self.select_from_e6_iqdb_data_where_not_exists(condition = nil, *args)
    where("not exists (#{select_from_e6_iqdb_data(condition)})", args)
  end

  def self.select_from_e6_iqdb_data(condition)
    "select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id #{"and #{condition}" if condition}"
  end

  def self.from_bin_file(bin_file, artist_submission_id:, url:, created_at:, file_identifier:)
    # Deviantart doesn't have to return only images.
    # No way to find this out through the api response as far as I'm aware.
    # https://www.deviantart.com/fr95/art/779625010/
    mime_type = Marcel::MimeType.for bin_file
    return if mime_type.in? Scraper::Submission::MIME_IGNORE

    submission_file = SubmissionFile.new(
      artist_submission_id: artist_submission_id,
      direct_url: url,
      created_at_on_site: created_at,
      file_identifier: file_identifier,
    )
    submission_file.set_original!(bin_file, url)
  end

  def set_original!(bin_file, url)
    filename = File.basename(Addressable::URI.parse(url).path)
    blob = ActiveStorage::Blob.create_and_upload!(io: bin_file, filename: filename)
    begin
      blob.analyze
      raise StandardError, "Failed to analyze" if blob.content_type == "application/octet-stream"

      original.attach(blob)
      self.width = blob.metadata[:width]
      self.height = blob.metadata[:height]
      self.content_type = blob.content_type
      self.size = blob.byte_size
      save!
    rescue StandardError => e
      blob.purge
      raise e
    end
  end

  def original_present
    errors.add(:original_file, "not attached") unless original.attached?
  end

  def md5
    Base64.decode64(original.checksum).unpack1("H*")
  end

  def can_iqdb?
    IqdbProxy.can_iqdb?(content_type)
  end

  def update_variants_and_iqdb
    return if attachment_changes["original"].blank?

    SubmissionFileUpdateJob.perform_later id
  end

  def update_e6_iqdb_data
    e6_iqdb_entries.destroy_all

    sample.open do |file|
      # FIXME: Error handling
      response = E6ApiClient.iqdb_query file
      json = JSON.parse(response.body)
      break unless json.is_a? Array

      json.each do |entry|
        post = entry["post"]["posts"]
        iqdb_entry = e6_iqdb_entries.create(
          post_id: post["id"],
          post_width: post["image_width"],
          post_height: post["image_height"],
          post_size: post["file_size"],
          post_is_deleted: post["is_deleted"],
          post_json: post,
          similarity_score: entry["score"],
          is_exact_match: md5 == post["md5"] || existing_matches(post["id"], is_exact_match: true).any?,
        )

        # Check if there are entries which were previously added
        # that are an exact visual match to this newly added exact match
        if iqdb_entry.is_exact_match
          existing_matches(post["id"], is_exact_match: false).find_each do |existing_match|
            existing_match.update(is_exact_match: true)
          end
        end
      end
    end
  end

  def existing_matches(post_id, is_exact_match:)
    E6IqdbData.joins(:submission_file)
              .where(post_id: post_id, submission_file: { iqdb_hash: iqdb_hash }, is_exact_match: is_exact_match)
  end

  def remove_from_iqdb
    IqdbProxy.remove_submission self if can_iqdb?
  end

  def update_e6_iqdb
    e6_iqdb_entries.destroy_all
    similar = IqdbProxy.query_submission_file(self).pluck(:submission)
    similar.each { |s| s.e6_iqdb_entries.destroy_all }

    E6IqdbQueryJob.set(priority: 10).perform_later id
    similar.each do |s|
      # Process matches from other artists after everything else.
      # Chances are that they're just wrong iqdb matches.
      priority = s.artist_submission.artist == artist_submission.artist ? 10 : -10
      E6IqdbQueryJob.set(priority: priority).perform_later s.id
    end
  end

  def generate_variants
    sample.attach(io: VariantGenerator.sample(original), filename: "sample")
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = status_search(params)
        q = q.attribute_matches(params[:content_type], :content_type)
        q = q.attribute_nil_check(params[:in_backlog], :added_to_backlog_at)
        q = q.attribute_nil_check(params[:hidden_from_search] || false, :hidden_from_search_at)
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
        [:artist_id, :site_type, :upload_status, :larger_only_filesize_treshold, :content_type, :title, :description, { artist_url_id: [] }]
      end
    end
  end
end
