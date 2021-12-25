class Artist < ApplicationRecord
  belongs_to_creator
  has_many :artist_urls
  has_many :submissions, through: :artist_urls

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, printable_string: true
  validates :name, length: { in: 1..64 }

  attr_accessor :url_string

  def recent_submissions
    submissions.includes(:submission_files).order(created_at_on_site: :desc).limit(10)
  end
end
