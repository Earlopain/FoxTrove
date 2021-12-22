module Scraper
  class Twitter
    # Inspired by https://github.com/JustAnotherArchivist/snscrape/blob/e7d35ec1ebb008108082fc79161f351bc8a707e4/snscrape/modules/twitter.py
    class ApiError < RuntimeError; end

    BEARER_TOKEN = "AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs=1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA".freeze
    REQUEST_URL = "https://twitter.com/i/api/2/search/adaptive.json".freeze
    GUEST_TOKEN_REGEX = /document\.cookie = decodeURIComponent\("gt=([0-9]*);/m.freeze
    REQUEST_RETRIES = 5
    DATETIME_FORMAT = "%a %b %d %H:%M:%S %z %Y".freeze

    def initialize(artist_url)
      @artist_url = artist_url
      @guest_token = nil
      @user_agent = random_user_agent
    end

    def scrape!
      # `filter:images` can't be used since it won't return sensitive media for guest accounts
      search = "from:#{@artist_url.identifier_on_site}"
      @guest_token = fetch_guest_token search
      make_request search
    end

    private

    def make_request(search)
      result = {}
      cursor = ""
      last_tweet_timestamp = DateTime.now + 60
      find_new_tweets_before_empty_response = false
      while true
        url = "#{REQUEST_URL}?#{query_string(search, cursor)}"
        response = HTTParty.get(url, headers: {
          "User-Agent": @user_agent,
          "Authorization": "Bearer #{BEARER_TOKEN}",
          "Referer": referer_url(search),
          "Accept-Language": "en-US,en;q=0.5",
          "x-guest-token": @guest_token,
        })
        # TODO: Error handling
        json = JSON.parse response.body
        tweets = response.dig("globalObjects", "tweets")

        # Cursors seem to only go that far and need to be refreshed every so often
        # Getting 0 tweets may either mean that this has happended, but it might
        # also be that there simply aren't any more resuls.
        # FIXME: On huge profiles cursors seem to get stuck. Refreshing returns
        # no tweets and using the new cursor from that also returns nothing.
        # What does work though is searching with `until:2030-01-01 since:2000-01-01`
        # and bypassing the timerange it gets stuck on. Good luck figuring
        # the gap out and being certain that the end wasn't simply reached.
        if tweets.count.zero?
          # Two times in a row no new tweets were found, even though the
          # cursor was reset
          return result if find_new_tweets_before_empty_response

          find_new_tweets_before_empty_response = true
          cursor = extract_cursor json, "top"
        else
          result.merge! extract_relevant_tweets(response)
          new_last_tweet_timestamp = DateTime.strptime(tweets.values.last["created_at"], DATETIME_FORMAT)
          find_new_tweets_before_empty_response = false if new_last_tweet_timestamp.before? last_tweet_timestamp
          last_tweet_timestamp = new_last_tweet_timestamp
          cursor = extract_cursor json, "bottom"
        end
        raise ApiError, "Failed to extract cursor: #{url}" if cursor.nil?
      end
    end

    def extract_relevant_tweets(response)
      response.dig("globalObjects", "tweets").reject do |_k, v|
        media = v.dig("extended_entities", "media")
        if media.nil?
          true # Exclude text tweets
        elsif media.count == 1 && media.first["expanded_url"].downcase.exclude?(@artist_url.identifier_on_site.downcase)
          true # Exclude quoted(?) tweets
        else
          false
        end
      end
    end

    def extract_cursor(json, type)
      instructions = json.dig("timeline", "instructions")
      return unless instructions

      instructions.filter_map do |instruction|
        entries = [instruction.dig("replaceEntry", "entry")] if instruction.key? "replaceEntry"
        entries = instruction.dig("addEntries", "entries") if instruction.key? "addEntries"
        next unless entries

        entries.filter_map do |entry|
          entry.dig("content", "operation", "cursor", "value") if entry["entryId"] == "sq-cursor-#{type}"
        end.first
      end.first
    end

    def random_user_agent
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.#{rand 9999} Safari/537.#{rand 99}"
    end

    def referer_url(search)
      params = {
        q: search,
        src: "typed_query",
      }
      "https://twitter.com/search?#{params.to_query}"
    end

    def fetch_guest_token(search)
      guest_token = nil
      tries = 0
      while guest_token.nil? && tries < REQUEST_RETRIES
        response = HTTParty.get(referer_url(search), headers: { "User-Agent": @user_agent })
        guest_token = response.body.scan(GUEST_TOKEN_REGEX).first&.first
        tries += 1
      end
      return guest_token unless guest_token.nil?

      raise ApiError, "Failed to get guest_token" if guest_token.nil?
    end

    def query_string(search, cursor)
      {
        tweet_search_mode: "live",
        tweet_mode: "extended",
        include_entities: false,
        include_ext_media_availability: true,
        q: search,
        query_source: "recent_search_click",
        cursor: cursor,
      }.to_query
    end
  end
end
