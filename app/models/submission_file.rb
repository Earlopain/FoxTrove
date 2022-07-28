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
  scope :larger_only_filesize, ->(treshold) { where("exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and size > post_size) and not exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and size - ? <= post_size)", treshold) }
  scope :larger_only_dimensions, -> { where("exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and width > post_width and height > post_height) and not exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id and width <= post_width and height <= post_height)") }
  scope :already_uploaded, -> { where("exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id)") }
  scope :not_uploaded, -> { where("not exists (select from e6_iqdb_data where submission_files.id = e6_iqdb_data.submission_file_id)") }
  scope :exact_match, -> { joins(:e6_iqdb_entries).where("size = post_size") }

  delegate :artist_url, :artist, to: :artist_submission

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

    blob = ActiveStorage::Blob.create_and_upload!(io: bin_file, filename: File.basename(url))
    begin
      blob.analyze
      raise StandardError, "Failed to analyze" if blob.content_type == "application/octet-stream"

      submission_file.original.attach(blob)
      submission_file.attributes = {
        width: blob.metadata[:width],
        height: blob.metadata[:height],
        content_type: blob.content_type,
        size: blob.byte_size,
      }
      submission_file.save
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
      response = E6ApiClient.iqdb_query file
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
          is_exact_match: md5 == post["md5"],
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
                size = (params[:larger_only_filesize_treshold] || 10).to_i.kilobytes
                q.send(params[:upload_status], size)
              when "larger_only_dimensions", "exact_match", "already_uploaded", "not_uploaded"
                q.send(params[:upload_status])
              else
                q.none
              end
        end
        q = q.attribute_matches(params[:content_type], :content_type)
        q = q.join_attribute_matches(params[:artist_url_id], artist_submission: { artist_url: :id })
        q = q.join_attribute_matches(params[:artist_id], artist_submission: { artist_url: { artist: :id } })
        q.order(created_at_on_site: :desc)
      end

      def search_params
        [:upload_status, :larger_only_filesize_treshold, :content_type, { artist_url_id: [] }]
      end
    end
  end
end
