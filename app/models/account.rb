class Account < ApplicationRecord
  has_many :artists, foreign_key: :creator_id
  has_many :artist_urls, foreign_key: :creator_id
  has_many :moderation_logs, foreign_key: :creator_id
end
