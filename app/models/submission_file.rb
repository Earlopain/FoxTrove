class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_one_attached :original
  has_one_attached :sample

  validate :original_present

  def original_present
    errors.add(:original_file, "not attached") unless original.attached?
  end

  def can_iqdb?
    IqdbProxy::VALID_CONTENT_TYPES.include? original.content_type
  end

  def generate_variants
    sample.attach(io: VariantGenerator.sample(original), filename: "sample")
  end
end
