# frozen_string_literal: true

class ArtistUrl < ApplicationRecord
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission", dependent: :destroy

  validate :set_api_identifier, on: :create
  validates :url_identifier, uniqueness: { scope: :site_type, case_sensitive: false }
  validates :api_identifier, uniqueness: { scope: :site_type, case_sensitive: false, allow_nil: true }

  enum site_type: %i[
    twitter furaffinity inkbunny sofurry
    deviantart artstation patreon pixiv
    weasyl tumblr reddit newgrounds
    vkontakte instagram subscribestar kofi
    twitch picarto fanbox piczel
    linktree carrd youtube_channel youtube_vanity
    youtube_legacy gumroad discord telegram
    skeb pawoo baraag hentai_foundry
    pillowfort commishes furrynetwork facebook
  ].map.with_index { |v, index| [v, index] }.to_h
  after_save :enqueue_scraping

  def set_api_identifier
    return unless scraper_enabled?

    scraper = site.new_scraper self
    self.api_identifier = scraper.fetch_api_identifier
    return if api_identifier

    errors.add(:identifier, "failed api lookup")
    throw :abort
  end

  def site
    @site ||= Sites.from_enum(site_type)
  end

  def scraper?
    site.is_a?(Sites::ScraperDefinition)
  end

  def scraper_enabled?
    scraper? && site.scraper_enabled?
  end

  def enqueue_scraping
    ScrapeArtistUrlWorker.perform_async id if scraper_enabled?
  end
end
