class User < ApplicationRecord
  class PrivilegeError < StandardError
    def initialize(msg = nil)
      super msg ? "Access Denied: #{msg}" : "Access Denied"
    end
  end

  enum level: {
    member: 0,
    admin: 100,
  }

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
    user.level = nil
    user.name = "anon"
    user.freeze.readonly!
    user
  end

  def anon?
    level.nil?
  end

  User.levels.each do |key, value|
    define_method("#{key}?") do
      !anon? && User.levels[level] >= value
    end
  end
end
