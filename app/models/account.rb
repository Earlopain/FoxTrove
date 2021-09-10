class Account < ApplicationRecord
  has_many :artists, foreign_key: :creator_id
  has_many :artist_urls, foreign_key: :creator_id
  has_many :created_moderation_logs, foreign_key: :creator_id, class_name: "ModerationLog"
end
