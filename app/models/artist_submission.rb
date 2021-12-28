class ArtistSubmission < ApplicationRecord
  belongs_to :artist_url
  has_one :site, through: :artist_url
  has_one :artist, through: :artist_url
  has_many :submission_files

  validates :identifier_on_site, uniqueness: { scope: :artist_url_id, case_sensitive: false }

  scope :with_samples, -> { includes(submission_files: [sample_attachment: :blob]) }
  scope :with_originals, -> { includes(submission_files: [original_attachment: :blob]) }
  scope :with_files, -> { with_samples.with_originals }
end
