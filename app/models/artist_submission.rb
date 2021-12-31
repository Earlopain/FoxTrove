class ArtistSubmission < ApplicationRecord
  belongs_to :artist_url
  has_one :site, through: :artist_url
  has_one :artist, through: :artist_url
  has_many :submission_files

  validates :identifier_on_site, uniqueness: { scope: :artist_url_id, case_sensitive: false }
end
