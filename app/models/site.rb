class Site < ApplicationRecord
  has_many :artist_urls, inverse_of: :site
  has_many :artists, through: :artist_urls
  has_many :submissions, through: :artist_urls
end
