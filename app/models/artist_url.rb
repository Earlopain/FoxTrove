# frozen_string_literal: true

class ArtistUrl < ApplicationRecord
  class MissingApiIdentifier < StandardError
    def initialize(url_identifier, site_type)
      msg = <<~MSG
        Missing API identifier for #{url_identifier}:#{site_type}.
        You may be able to fix this by executing the following command:

        docker compose run --rm reverser bin/rails reverser:backfill_api_identifiers SITE_TYPE=#{site_type}
      MSG
      super(msg)
    end
  end

  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission", dependent: :destroy

  validates :url_identifier, uniqueness: { scope: :site_type, case_sensitive: false }
  validates :api_identifier, uniqueness: { scope: :site_type, case_sensitive: false, allow_nil: true }
  after_create :set_api_identifier!

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
    afterdark artconomy artfight boosty
    buzzly furrystation toyhouse ychart
    manual trello itaku artfol
    cohost inkblot bluesky
  ].map.with_index { |v, index| [v, index] }.to_h

  def self.search(params)
    q = join_attribute_nil_check(params[:in_backlog], submissions: { submission_files: :added_to_backlog_at })
    q = q.join_attribute_nil_check(params[:hidden_from_search], submissions: { submission_files: :hidden_from_search_at })
    q = q.attribute_matches(params[:site_type], :site_type)
    q = q.attribute_matches(params[:url_identifier], :url_identifier)
    q = q.attribute_matches(params[:api_identifier], :api_identifier)
    q.order(id: :desc)
  end

  def set_api_identifier!
    return unless scraper_enabled?

    begin
      self.api_identifier = scraper.fetch_api_identifier
    rescue HTTPX::HTTPError => e
      raise e unless e.status == 404
    end

    if api_identifier
      save
    else
      errors.add(:base, "#{url_identifier} failed api lookup")
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
