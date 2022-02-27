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
      @auth_token, @csrf_token = Cache.fetch("twitter-tokens", 55.minutes) do
        fetch_tokens
      end
      @cursor = ""
      @find_new_tweets_before_empty_response = false
      @all_tweets_ids = []
    end

    def self.enabled?
      Config.twitter_user.present? && Config.twitter_pass.present?
    end

    def fetch_next_batch
      response = make_request(@search, @cursor)
      # FIXME: Might be nil
      tweets = response.dig("globalObjects", "tweets")
      new_tweet_ids = relevant_tweet_ids(tweets).difference(@all_tweets_ids)
      @all_tweets_ids += new_tweet_ids

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

      tweet["extended_entities"]["media"].each.with_index do |media, index|
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
        created_at = extract_timestamp(tweet)
        s.created_at = created_at
        s.add_file({
          url: url,
          created_at: created_at,
          identifier: index,
        })
      end
      s
    end

    def extract_timestamp(tweet)
      DateTime.strptime(tweet["created_at"], DATETIME_FORMAT)
    end

    private

    def make_request(search, cursor)
      url = "#{REQUEST_URL}?#{query_string(search, cursor)}"
      response = HTTParty.get(url, headers: {
        **api_headers(search),
        "x-csrf-token": @csrf_token,
        "Cookie": "ct0=#{@csrf_token}; auth_token=#{@auth_token}",
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

    def fetch_tokens
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://twitter.com/"
        wait = Selenium::WebDriver::Wait.new(timeout: 10)
        # There are two different layouts for the homepage, the loginflow is always the same though
        wait.until { driver.find_element(xpath: "//*[text()='Sign in'] | //*[text()='Log in']") }.click

        wait.until { driver.find_element(css: "input[autocomplete='username']") }.send_keys Config.twitter_user
        driver.find_element(xpath: "//*[text()='Next']").click

        wait.until { driver.find_element(css: "input[type='password']") }.send_keys Config.twitter_pass
        driver.find_element(xpath: "//*[text()='Log in']").click

        if Config.twitter_otp_secret.present?
          otp = ROTP::TOTP.new(Config.twitter_otp_secret).now
          wait.until { driver.find_element(css: "input") }.send_keys otp
          driver.find_element(xpath: "//*[text()='Next']").click
        end

        # The auth_token cookie isn't available immediately, so wait a bit
        auth_token = wait.until { driver.manage.cookie_named("auth_token")[:value] rescue nil }
        csrf_token = driver.manage.cookie_named("ct0")[:value]
        [auth_token, csrf_token]
      end
    end

    def api_headers(search)
      {
        "User-Agent": @user_agent,
        "Authorization": "Bearer #{BEARER_TOKEN}",
        "Referer": referer_url(search),
        "Accept-Language": "en-US,en;q=0.5",
      }
    end

    def referer_url(search)
      params = {
        q: search,
        src: "typed_query",
      }
      "https://twitter.com/search?#{params.to_query}"
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

    def random_user_agent
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.#{rand 9999} Safari/537.#{rand 99}"
    end
  end
end
