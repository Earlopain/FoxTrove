class User < ApplicationRecord
  module Levels
    UNACTIVATED = "unactivated".freeze
    MEMBER = "member".freeze
    ADMIN = "admin".freeze
  end

  module Permissions
    DELETE_ARTIST = "delete_artist".freeze
    REQUEST_MANUAL_UPDATE = "request_manual_update".freeze
    ALLOW_URL_MODERATION = "allow_url_moderation".freeze
  end

  has_many :created_artists, foreign_key: :creator_id, class_name: "Artist"
  has_many :created_artist_urls, foreign_key: :creator_id, class_name: "ArtistUrl"
  has_many :created_moderation_logs, foreign_key: :creator_id, class_name: "ModerationLog"

  has_secure_password
  validates :password, length: { minimum: 6 }, if: ->(rec) { rec.new_record? || rec.password.present? }

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, printable_string: true
  validates :name, length: { in: 5..20 }
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.anon
    user = User.new
    user.level = Levels::UNACTIVATED
    user.name = "anon"
    user.freeze.readonly!
    user
  end
end
