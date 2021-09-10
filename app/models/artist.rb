class Artist < ApplicationRecord
  belongs_to_creator
  has_many :artist_urls
  has_many :submissions, through: :artist_urls
end
