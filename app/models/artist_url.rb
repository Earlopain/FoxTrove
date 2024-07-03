# frozen_string_literal: true

class ArtistUrl < ApplicationRecord
  class MissingApiIdentifier < StandardError
    def initialize(url_identifier, site_type)
      msg = <<~MSG
        Missing API identifier for #{url_identifier}:#{site_type}.
        You may be able to fix this by executing the following command:

        docker compose run --rm foxtrove bin/rails foxtrove:backfill_api_identifiers SITE_TYPE=#{site_type}
      MSG
      super(msg)
    end
  end

  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission", dependent: :destroy

  validates :url_identifier, uniqueness: { scope: :site_type, case_sensitive: false }
  validates :api_identifier, uniqueness: { scope: :site_type, case_sensitive: false, allow_nil: true }
  after_create :set_api_identifier!
  after_create_commit :enqueue_scraping

  enum :site_type, %i[
    twitter furaffinity inkbunny sofurry
    deviantart artstation patreon pixiv
    weasyl tumblr reddit newgrounds
    vkontakte instagram subscribestar kofi
    twitch picarto fanbox piczel
    linktree carrd youtube_channel youtube_vanity
    youtube_legacy gumroad discord telegram
    skeb pawoo baraag hentai_foundry
    pillowfort commishes furrynetwork facebook
    afterdark artconomy artfight boosty
    buzzly furrystation toyhouse ychart
    manual trello itaku artfol
    cohost inkblot bluesky omorashi
    threads
  ].map.with_index { |v, index| [v, index] }.to_h

  def self.search(params)
    q = join_attribute_nil_check(params[:in_backlog], submissions: { submission_files: :added_to_backlog_at })
    q = q.join_attribute_nil_check(params[:hidden_from_search], submissions: { submission_files: :hidden_from_search_at })
    q = q.attribute_matches(params[:site_type], :site_type)
    q = q.attribute_matches(params[:url_identifier], :url_identifier)
    q = q.attribute_matches(params[:api_identifier], :api_identifier)
    if params[:missing_api_identifier] == "1"
      scrapers = Sites.definitions.select(&:scraper_enabled?).map(&:site_type)
      q = q.attribute_nil_check("false", :api_identifier).attribute_matches(scrapers, :site_type)
    end
    q.order(id: :desc)
  end

  def set_api_identifier!
    return unless scraper_enabled?

    begin
      self.api_identifier = scraper.fetch_api_identifier
    rescue HTTPX::HTTPError => e
      http_status_error = e.status
    end

    if api_identifier
      save
    else
      error_message = "#{url_identifier} failed api lookup"
      error_message << " (#{Rack::Utils::HTTP_STATUS_CODES[http_status_error]})" if http_status_error
      errors.add(:base, error_message)
    end
  end

  def unescaped_url_identifier
    CGI.unescape(url_identifier)
  end

  def site
    @site ||= Sites.from_enum(site_type)
  end

  delegate :scraper?, :scraper_enabled?, to: :site

  def scraper
    site.new_scraper(self)
  end

  def enqueue_scraping
    return unless scraper_enabled?
    raise MissingApiIdentifier.new(url_identifier, site_type) unless api_identifier

    ScrapeArtistUrlJob.perform_later(self)
  end
end
