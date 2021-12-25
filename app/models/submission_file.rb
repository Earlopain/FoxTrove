class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_one_attached :original
  has_one_attached :sample
  has_one_attached :iqdb_thumb

  validate :original_present

  def original_present
    errors.add(:original_file, "not attached") unless original.attached?
  end

  def can_iqdb?
    ["image/png", "image/jpeg"].include? original.content_type
  end

  def generate_variants
    sample.attach(io: VariantGenerator.sample(original), filename: "sample")
    return unless can_iqdb?

    iqdb_thumb.attach(io: VariantGenerator.iqdb_thumb(original), filename: "iqdb_thumb")
  end
end
