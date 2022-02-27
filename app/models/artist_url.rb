class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, optional: true, class_name: "User"
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission", dependent: :destroy

  validate :set_api_identifier, on: :create
  validates :identifier_on_site, uniqueness: { scope: :site_type, case_sensitive: false }
  validates :api_identifier, uniqueness: { scope: :site_type, case_sensitive: false }

  after_save :enqueue_scraping

  def set_api_identifier
    return unless site.scraper_enabled?

    scraper = site.new_scraper self
    self.api_identifier = scraper.fetch_api_identifier
    return if api_identifier

    errors.add(:identifier, "failed api lookup")
    throw :abort
  end

  def site
    @site ||= Sites.from_enum(site_type)
  end

  def enqueue_scraping
    ScrapeArtistUrlWorker.perform_async id if site.scraper_enabled?
  end
end
