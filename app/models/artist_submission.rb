class ArtistSubmission < ApplicationRecord
  belongs_to :artist_url
  has_one :site, through: :artist_url
  has_one :artist, through: :artist_url
end
