class ArtistSubmission < ApplicationRecord
  module Extensions
    PNG = "png".freeze
    JPG = "jpg".freeze
    GIF = "gif".freeze
    WEBM = "webm".freeze
  end

  belongs_to :artist_url
  has_one :site, through: :artist_url
  has_one :artist, through: :artist_url
end
