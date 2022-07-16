class ArtistUrl < ApplicationRecord
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission", dependent: :destroy

  validate :set_api_identifier, on: :create
  validates :url_identifier, uniqueness: { scope: :site_type, case_sensitive: false }
  validates :api_identifier, uniqueness: { scope: :site_type, case_sensitive: false, allow_nil: true }

  enum site_type: {
    twitter: 0,
    furaffinity: 1,
    inkbunny: 2,
    sofurry: 3,
    deviantart: 4,
    artstation: 5,
    patreon: 6,
    pixiv: 7,
    weasyl: 8,
    tumblr: 9,
    reddit: 10,
    newgrounds: 11,
    vkontakte: 12,
    instagram: 13,
    subscribestar: 14,
    kofi: 15,
    twitch: 16,
    picarto: 17,
    fanbox: 18,
    piczel: 19,
    linktree: 20,
    carrd: 21,
    youtube_channel: 22,
    youtube_vanity: 23,
    youtube_legacy: 24,
    gumroad: 25,
    discord: 26,
    telegram: 27,
    skeb: 28,
    pawoo: 29,
    baraag: 30,
    hentai_foundry: 31,
    pillowfort: 32,
    commishes: 33,
    furrynetwork: 34,
    facebook: 35,
  }

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
