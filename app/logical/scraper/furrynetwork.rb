# frozen_string_literal: true

module Scraper
  class Furrynetwork < Base
    STATE = :offset

    PER_REQUEST = 72
    API_PREFIX = "https://furrynetwork.com/api"

    def initialize(artist_url)
      super
      @offset = 0
    end

    def fetch_next_batch
      # This fetches EVERYTHING. Terribly sorry about that but I can't circumentvent the login captcha
      json = make_request("/character/#{url_identifier}/artwork")
      end_reached
      json.sort_by do |entry|
        # 1274418 (NSFW) has published: nil, fall back to something else instead
        DateTime.parse(entry["published"] || entry["created"])
      end
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["description"] || ""
      s.created_at = DateTime.parse submission["created"]

      s.add_file({
        url: submission["images"]["original"],
        created_at: s.created_at,
        identifier: "",
      })
      s
    end

    def fetch_api_identifier
      make_request("/character/#{url_identifier}")["id"]
    rescue JSON::ParserError
      # Some characters (the_secret_cave) return php error traces with status code 200 because why not
      entries = make_request("/character/#{url_identifier}/artwork")
      entries&.first&.dig("character_id")
    end

    private

    def make_request(endpoint)
      fetch_json("#{API_PREFIX}#{endpoint}")
    end
  end
end
