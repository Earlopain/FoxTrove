class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_one_attached :original
  has_one_attached :sample
  has_many :e6_iqdb_entries, class_name: "E6IqdbData", dependent: :destroy
  has_many :backlogs

  validate :original_present

  after_destroy_commit :remove_from_iqdb
  after_save_commit :update_variants_and_iqdb

  scope :with_attached, -> { with_attached_sample.with_attached_original }
  scope :with_everything, ->(user_id) do
    query = with_attached.includes(:e6_iqdb_entries, :backlogs, artist_submission: :artist_url)
    query = query.joins("left outer join backlogs on backlogs.submission_file_id = submission_files.id and backlogs.user_id = #{user_id}") if user_id
    query
  end
  scope :larger_only_filesize, ->(treshold) { where("exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and size > post_size) and not exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and size - ? <= post_size)", treshold) }
  scope :larger_only_dimensions, -> { where("exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and width > post_width and height > post_height) and not exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and width <= post_width and height <= post_height)") }
  scope :larger_only_both, ->(treshhold) { larger_only_filesize(treshhold).larger_only_dimensions }
  scope :already_uploaded, -> { where("exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id)") }
  scope :not_uploaded, -> { where("not exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id)") }
  scope :exact_match, -> { joins(:e6_iqdb_entries).where("size = post_size") }

  def artist
    artist_submission.artist_url.artist
  end

  def artist_url
    artist_submission.artist_url
  end

  def original_present
    errors.add(:original_file, "not attached") unless original.attached?
  end

  def md5
    Base64.decode64(original.checksum).unpack1("H*")
  end

  def can_iqdb?
    IqdbProxy::VALID_CONTENT_TYPES.include? original.content_type
  end

  def update_variants_and_iqdb
    return if attachment_changes["original"].blank?

    SubmissionFileUpdateWorker.perform_async id
  end

  def update_e6_iqdb_data(remove_similar:)
    e6_iqdb_entries.destroy_all
    sample.open do |file|
      # FIXME: Error handling
      response = E6Iqdb.query file
      json = JSON.parse(response.body)
      break unless json.is_a? Array

      json.each do |entry|
        post = entry["post"]["posts"]
        e6_iqdb_entries.create(
          post_id: post["id"],
          post_width: post["image_width"],
          post_height: post["image_height"],
          post_size: post["file_size"],
          similarity_score: entry["score"],
          is_exact_match: md5 == post["md5"]
        )
      end
    end
    return unless remove_similar

    IqdbProxy.query_submission_file(self).pluck(:submission).each do |similar|
      E6IqdbQueryWorker.perform_async similar.id, false
    end
  end

  def remove_from_iqdb
    IqdbProxy.remove_submission self if can_iqdb?
  end

  def generate_variants
    sample.attach(io: VariantGenerator.sample(original), filename: "sample")
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = all
        if params[:upload_status].present?
          q = case params[:upload_status]
              when "larger_only_filesize"
                q.larger_only_filesize((params[:larger_only_filesize_treshold] || 10).to_i.kilobytes)
              when "larger_only_dimensions"
                q.larger_only_dimensions
              when "larger_only_both"
                q.larger_only_both((params[:larger_only_filesize_treshold] || 10).to_i.kilobytes)
              when "exact_match"
                q.exact_match
              when "already_uploaded"
                q.already_uploaded
              when "not_uploaded"
                q.not_uploaded
              else
                q.none
              end
        end
        q = q.attributes_matching(%i[artist_url_id artist_id content_type], params)
        q.order(created_at_on_site: :desc)
      end

      def shorthand_attribute_access
        {
          artist_url_id: { artist_submission: { artist_url: :id } },
          artist_id: { artist_submission: { artist_url: { artist: :id } } },
        }
      end
    end
  end
end
