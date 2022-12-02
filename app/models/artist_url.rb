# frozen_string_literal: true

class ArtistUrl < ApplicationRecord
  class MissingApiIdentifier < StandardError
    def initialize(url_identifier, site_type)
      msg = <<~MSG
        Missing API identifier for #{url_identifier}:#{site_type}.
        See fixer script No. 5 to backfill missing data.

        docker-compose run --rm reverser bin/rails reverser:backfill_api_identifiers SITE_TYPE=#{site_type}
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
  ].map.with_index { |v, index| [v, index] }.to_h

  def self.search(params)
    q = join_attribute_nil_check(params[:in_backlog], submissions: { submission_files: :added_to_backlog_at })
    q.join_attribute_nil_check(params[:hidden_from_search], submissions: { submission_files: :hidden_from_search_at })
  end

  def set_api_identifier!
    return unless scraper_enabled?

    scraper = site.new_scraper self
    self.api_identifier = scraper.fetch_api_identifier
    if api_identifier
      save
    else
      errors.add(:base, "#{url_identifier} failed api lookup")
    end
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
    raise MissingApiIdentifier.new(url_identifier, site_type) unless api_identifier

    ScrapeArtistUrlJob.perform_later id if scraper_enabled?
  end
end
