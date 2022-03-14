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
  validates :e6_user_id, uniqueness: true
  validate :set_e6_data, on: :create

  attr_accessor :api_key

  def set_e6_data
    e6_user = E6ApiClient.new(name, api_key).user_by_name(name)
    if e6_user["success"] == false
      errors.add(:api_key, "is not valid")
      throw :abort
    end
    if e6_user["email"].blank?
      errors.add(:api_key, "does not match the user")
      throw :abort
    end
    self.name = e6_user["name"]
    self.e6_user_id = e6_user["id"]
    self.time_zone = e6_user["time_zone"]
  end

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
