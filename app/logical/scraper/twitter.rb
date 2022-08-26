# frozen_string_literal: true

module Scraper
  class Twitter < Base
    # Inspired by https://github.com/JustAnotherArchivist/snscrape/blob/e7d35ec1ebb008108082fc79161f351bc8a707e4/snscrape/modules/twitter.py
    class ApiError < RuntimeError; end

    BEARER_TOKEN = "AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs=1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA"
    DATETIME_FORMAT = "%a %b %d %H:%M:%S %z %Y"
    API_BASE_URL = "https://twitter.com/i/api/graphql"

    def init
      @user_agent = random_user_agent
      @cursor = ""
    end

    def self.enabled?
      Config.twitter_user.present? && Config.twitter_pass.present? && Config.selenium_url.present?
    end

    def fetch_next_batch
      params = {
        userId: api_identifier,
        count: 100,
        includePromotedContent: false,
        withSuperFollowsUserFields: false,
        withDownvotePerspective: false,
        withReactionsMetadata: false,
        withReactionsPerspective: false,
        withSuperFollowsTweetFields: false,
        withClientEventToken: false,
        withBirdwatchNotes: false,
        withVoice: false,
        withV2Timeline: true,
      }
      params[:cursor] = @cursor if @cursor.present?
      response = make_request("laAWxgrzEYIlGLcOucDFMw/UserMedia", params)

      if response.dig("data", "user", "result", "__typename") == "UserUnavailable"
        end_reached
        return []
      end

      tweets, cursor_entry = extract_tweets_and_cursor_entry(response)
      @cursor = cursor_entry["value"]
      end_reached if tweets.empty? && cursor_entry["stopOnEmptyResponse"]
      tweets
    end

    def to_submission(tweet_data)
      s = Submission.new
      tweet = tweet_data["legacy"]
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
      s.created_at = DateTime.strptime(tweet_data["legacy"]["created_at"], DATETIME_FORMAT)

      tweet["extended_entities"]["media"].each.with_index do |media, index|
        url = extract_url_from_media(media)
        s.add_file({
          url: url,
          created_at: s.created_at,
          identifier: index,
        })
      end
      s
    end

    def fetch_api_identifier
      user_json = make_request("7mjxD3-C6BxitPMVQ6w0-Q/UserByScreenName", {
        screen_name: url_identifier,
        withSuperFollowsUserFields: true,
      })
      user_json.dig("data", "user", "result", "rest_id")
    end

    private

    def extract_tweets_and_cursor_entry(response)
      instructions = response.dig("data", "user", "result", "timeline_v2", "timeline", "instructions")
      timeline_add_entries = instructions.find { |instruction| instruction["type"] == "TimelineAddEntries" }["entries"].map { |entry| entry["content"] }
      tweets = entries_by_type(timeline_add_entries, "TimelineTimelineItem").map { |content| content.dig("itemContent", "tweet_results", "result") }.compact
      # Tweets deleted by the author
      tweets = tweets.reject { |tweet| tweet["__typename"] == "TweetTombstone" }
      # Tweets without downloadable content, like embeded youtube videos
      tweets = tweets.select { |tweet| tweet.dig("legacy", "extended_entities", "media") }
      cursor_entry = entries_by_type(timeline_add_entries, "TimelineTimelineCursor").find { |cursor| cursor["cursorType"] == "Bottom" }
      [tweets, cursor_entry]
    end

    def entries_by_type(entries, type)
      entries.select { |entry| entry["entryType"] == type }
    end

    def extract_url_from_media(media)
      case media["type"]
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
    end

    def make_request(url, params = {})
      fetch_json("#{API_BASE_URL}/#{url}", query: { variables: params.to_json }, headers: api_headers)
    end

    def tokens
      Cache.fetch("twitter-tokens", 55.minutes) do
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
          auth_token = wait.until { driver.cookie_value("auth_token") }
          csrf_token = driver.cookie_value("ct0")
          [auth_token, csrf_token]
        end
      end
    end

    def api_headers
      auth_token, csrf_token = tokens
      {
        "User-Agent": @user_agent,
        "Authorization": "Bearer #{BEARER_TOKEN}",
        "Referer": "https://twitter.com/#{url_identifier}/media",
        "Accept-Language": "en-US,en;q=0.5",
        "x-csrf-token": csrf_token,
        "Cookie": "ct0=#{csrf_token}; auth_token=#{auth_token}",
      }
    end

    def random_user_agent
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.#{rand 9999} Safari/537.#{rand 99}"
    end
  end
end
