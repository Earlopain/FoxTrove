module Scraper
  class Twitter < Base
    # Inspired by https://github.com/JustAnotherArchivist/snscrape/blob/e7d35ec1ebb008108082fc79161f351bc8a707e4/snscrape/modules/twitter.py
    class ApiError < RuntimeError; end

    BEARER_TOKEN = "AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs=1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA".freeze
    REQUEST_URL = "https://twitter.com/i/api/2/search/adaptive.json".freeze
    GUEST_TOKEN_REGEX = /document\.cookie = decodeURIComponent\("gt=([0-9]*);/m.freeze
    REQUEST_RETRIES = 5
    DATETIME_FORMAT = "%a %b %d %H:%M:%S %z %Y".freeze

    def init
      # `filter:images` can't be used since it won't return sensitive media for guest accounts
      @search = "from:#{@identifier} -filter:retweets"
      @user_agent = random_user_agent
      @guest_token = Cache.fetch("twitter-guest-token", 1.hour) do
        fetch_guest_token(@search)
      end
      @cursor = ""
      @find_new_tweets_before_empty_response = false
      @all_tweets_ids = []
    end

    def enabled?
      true
    end

    def last_scraped_submission_identifier
      @all_tweets_ids.map(&:to_i).max
    end

    def fetch_next_batch
      response = make_request(@search, @cursor)
      # FIXME: Might be nil
      tweets = response.dig("globalObjects", "tweets")
      new_tweet_ids = relevant_tweet_ids(tweets).difference(@all_tweets_ids)
      @all_tweets_ids += new_tweet_ids
      end_reached if new_tweet_ids.map(&:to_i).any? { |id| id < @stop_marker.to_i }

      # Cursors seem to only go that far and need to be refreshed every so often
      # Getting 0 tweets may either mean that this has happended, but it might
      # also be that there simply aren't any more resuls.
      # FIXME: On huge profiles cursors seem to get stuck. Refreshing returns
      # no tweets and using the new cursor from that also returns nothing.
      # What does work though is searching with `until:2030-01-01 since:2000-01-01`
      # and bypassing the timerange it gets stuck on. Good luck figuring
      # the gap out and being certain that the end wasn't simply reached.
      if tweets.count == 0
        # Two times in a row no new tweets were found, even though the
        # cursor was reset
        end_reached if @find_new_tweets_before_empty_response

        @find_new_tweets_before_empty_response = true
        @cursor = extract_cursor response, "top"
      else
        @find_new_tweets_before_empty_response = false if new_tweet_ids.present?
        @cursor = extract_cursor response, "bottom"
      end
      raise ApiError, "Failed to extract cursor: #{url}" if @cursor.nil?

      new_tweet_ids.map { |id| tweets[id] }
    end

    def to_submission(tweet)
      s = Submission.new
      s.identifier = tweet["id_str"]
      s.title = ""

      range = tweet["display_text_range"]
      description = if range[0] == range[1]
                      ""
                    else
                      tweet["full_text"][range[0]..range[1]]
                    end
      tweet["entities"]["urls"].each do |entry|
        indices = entry["indices"]
        description[indices[0]..indices[1]] = entry["expanded_url"]
      end
      s.description = description

      tweet["extended_entities"]["media"].each do |media|
        url = case media["type"]
              when "photo"
                # https://pbs.twimg.com/media/Ek086oLVgAMjX5h.jpg => https://pbs.twimg.com/media/Ek086oLVgAMjX5h?format=jpg&name=orig
                regex = %r{media/(\S*)\.(\S*)$}
                name, ext = media["media_url_https"].scan(regex).first
                "https://pbs.twimg.com/media/#{name}?format=#{ext}&name=orig"
              when "video"
                # get the variant with the highest bitrate
                variant = media.dig("video_info", "variants").max_by { |v| v["bitrate"].to_i }
                variant["url"]
              when "animated_gif"
                # there is only one variant, get that
                media.dig("video_info", "variants").first["url"]
              else
                raise ApiError, "Unknown media type #{media['type']}"
              end
        created_at = DateTime.strptime(tweet["created_at"], DATETIME_FORMAT)
        s.created_at = created_at
        s.files.push({
          url: url,
          created_at: created_at,
        })
      end
      s
    end

    private

    def make_request(search, cursor)
      url = "#{REQUEST_URL}?#{query_string(search, cursor)}"
      response = HTTParty.get(url, headers: {
        "User-Agent": @user_agent,
        "Authorization": "Bearer #{BEARER_TOKEN}",
        "Referer": referer_url(search),
        "Accept-Language": "en-US,en;q=0.5",
        "x-guest-token": @guest_token,
      })
      # TODO: Error handling
      JSON.parse response.body
    end

    def relevant_tweet_ids(tweets)
      quoted_tweet_ids = []
      tweet_ids = tweets.filter_map do |tweet_id, tweet|
        media = tweet.dig("extended_entities", "media")
        quoted_tweet_ids.push(tweet["quoted_status_id_str"]) if tweet["quoted_status_id_str"]
        # Exclude text tweets
        tweet_id unless media.nil?
      end
      # Exclude quoted tweets
      tweet_ids.difference quoted_tweet_ids
    end

    def extract_cursor(response, type)
      instructions = response.dig("timeline", "instructions")
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
        sleep 5 if tries > 0
        response = HTTParty.get(referer_url(search), headers: { "User-Agent": @user_agent })
        guest_token = response.body.scan(GUEST_TOKEN_REGEX).first&.first
        tries += 1
      end
      raise ApiError, "Failed to get guest_token" unless guest_token

      guest_token
    end

    def query_string(search, cursor)
      {
        tweet_search_mode: "live",
        tweet_mode: "extended",
        include_entities: true,
        include_ext_media_availability: true,
        q: search,
        query_source: "recent_search_click",
        cursor: cursor,
      }.to_query
    end
  end
end
