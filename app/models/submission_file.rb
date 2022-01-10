class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_one_attached :original
  has_one_attached :sample
  has_many :e6_iqdb_entries, class_name: "E6IqdbData", dependent: :destroy

  validate :original_present

  after_destroy_commit :remove_from_iqdb
  after_save_commit :update_variants_and_iqdb

  scope :with_attached, -> { with_attached_sample.with_attached_original }

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

  def update_e6_iqdb_data
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
  end

  def remove_from_iqdb
    IqdbProxy.remove_submission self if can_iqdb?
  end

  def generate_variants
    sample.attach(io: VariantGenerator.sample(original), filename: "sample")
  end
end
