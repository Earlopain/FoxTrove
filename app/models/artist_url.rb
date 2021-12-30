class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, optional: true, class_name: "User"
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission"

  validates :identifier_on_site, uniqueness: { scope: :site_type, case_sensitive: false }

  after_save :enqueue_scraping

  def site
    @site ||= Sites.from_enum(site_type)
  end

  def scraper
    site.scraper.new self
  end

  def enqueue_scraping
    ScrapeArtistUrlWorker.perform_async id
  end
end
