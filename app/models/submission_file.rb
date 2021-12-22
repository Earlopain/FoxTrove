class SubmissionFile < ApplicationRecord
  belongs_to :artist_submission
  has_one_attached :file do |attachable|
    attachable.variant :thumb, resize_to_limit: [Reverser.thumbnail_size, Reverser.thumbnail_size], format: :jpg
  end

  validate :file_present

  def file_present
    errors.add(:attached_file, "no file added") unless file.attached?
  end
end
