class ArtistSubmission < ApplicationRecord
  belongs_to :artist_url
  has_one :site, through: :artist_url
  has_one :artist, through: :artist_url
  has_one_attached :file do |attachable|
    attachable.variant :iqdb_thumb, resize_to_limit: [128, 128], format: :jpg
    attachable.variant :thumb, resize_to_limit: [Reverser.thumbnail_size, Reverser.thumbnail_size], format: :jpg
  end

  validate :file_present

  def file_present
    errors.add(:attached_file, "no file added") unless file.attached?
  end
end
