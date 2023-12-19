# frozen_string_literal: true

module Scraper
  class Twitter < Base
    # Inspired by https://github.com/JustAnotherArchivist/snscrape/blob/e7d35ec1ebb008108082fc79161f351bc8a707e4/snscrape/modules/twitter.py
    class ApiError < RuntimeError; end

    BEARER_TOKEN = "AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs=1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA"
    DATETIME_FORMAT = "%a %b %d %H:%M:%S %z %Y"
    API_BASE_URL = "https://twitter.com/i/api/graphql"

    def initialize(artist_url)
      super
      @user_agent = random_user_agent
      @cursor = ""
    end

    def self.optional_config_keys
      %i[twitter_otp_secret]
    end

    def self.state
      :cursor
    end

    def fetch_next_batch
      variables = {
        userId: api_identifier,
        count: 100,
        includePromotedContent: false,
        withClientEventToken: false,
        withBirdwatchNotes: false,
        withVoice: true,
        withV2Timeline: true,
      }
      features = {
        responsive_web_graphql_exclude_directive_enabled: true,
        verified_phone_label_enabled: false,
        creator_subscriptions_tweet_preview_api_enabled: true,
        responsive_web_graphql_timeline_navigation_enabled: true,
        responsive_web_graphql_skip_user_profile_image_extensions_enabled: false,
        c9s_tweet_anatomy_moderator_badge_enabled: true,
        tweetypie_unmention_optimization_enabled: true,
        responsive_web_edit_tweet_api_enabled: true,
        graphql_is_translatable_rweb_tweet_is_translatable_enabled: true,
        view_counts_everywhere_api_enabled: true,
        longform_notetweets_consumption_enabled: true,
        responsive_web_twitter_article_tweet_consumption_enabled: false,
        tweet_awards_web_tipping_enabled: false,
        freedom_of_speech_not_reach_fetch_enabled: true,
        standardized_nudges_misinfo: true,
        tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled: true,
        rweb_video_timestamps_enabled: true,
        longform_notetweets_rich_text_read_enabled: true,
        longform_notetweets_inline_media_enabled: true,
        responsive_web_media_download_video_enabled: false,
        responsive_web_enhance_cards_enabled: false,
      }
      variables[:cursor] = @cursor if @cursor.present?
      params = { variables: variables, features: features }
      response = make_request("oMVVrI5kt3kOpyHHTTKf5Q/UserMedia", params)

      if response.dig("data", "user", "result", "__typename") == "UserUnavailable"
        end_reached
        return []
      end

      tweets, cursor_entry = extract_tweets_and_cursor_entry(response)
      @cursor = cursor_entry["value"]
      end_reached if tweets.empty?
      tweets
    end

    def to_submission(tweet_data)
      s = Submission.new
      tweet = tweet_data["legacy"]
      s.identifier = tweet["id_str"]
      s.title = ""
      s.description = expand_description(tweet)
      s.created_at = DateTime.strptime(tweet["created_at"], DATETIME_FORMAT)

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
      variables = {
        screen_name: url_identifier,
        withSafetyModeUserFields: true,
      }
      features = {
        hidden_profile_likes_enabled: true,
        hidden_profile_subscriptions_enabled: true,
        responsive_web_graphql_exclude_directive_enabled: true,
        verified_phone_label_enabled: false,
        subscriptions_verification_info_is_identity_verified_enabled: true,
        subscriptions_verification_info_verified_since_enabled: true,
        highlights_tweets_tab_ui_enabled: true,
        responsive_web_twitter_article_notes_tab_enabled: false,
        creator_subscriptions_tweet_preview_api_enabled: true,
        responsive_web_graphql_skip_user_profile_image_extensions_enabled: false,
        responsive_web_graphql_timeline_navigation_enabled: true,
      }
      field_toggles = {
        withAuxiliaryUserLabels: false,
      }
      params = { variables: variables, features: features, fieldToggles: field_toggles }
      user_json = make_request("NimuplG1OB7Fd2btCLdBOw/UserByScreenName", params)
      user_json.dig("data", "user", "result", "rest_id")
    end

    private

    def extract_tweets_and_cursor_entry(response)
      instructions = response.dig("data", "user", "result", "timeline_v2", "timeline", "instructions")
      timeline_add_entries = instruction_by_type(instructions, "TimelineAddEntries")["entries"].pluck("content")
      items = extract_items(instructions, timeline_add_entries)
      item_content = items.filter_map { |item| item.dig("item", "itemContent") }
      tweets = item_content.reject { |content| content["promotedMetadata"] }.filter_map { |content| content.dig("tweet_results", "result") }
      # Tweets deleted by the author
      tweets = tweets.reject { |tweet| tweet["__typename"] == "TweetTombstone" }
      # Tweets without downloadable content, like embeded youtube videos
      tweets = tweets.select { |tweet| tweet.dig("legacy", "extended_entities", "media") }
      cursor_entry = entries_by_type(timeline_add_entries, "TimelineTimelineCursor").find { |cursor| cursor["cursorType"] == "Bottom" }
      [tweets, cursor_entry]
    end

    def extract_items(instructions, timeline_add_entries)
      if (add_to_module = instruction_by_type(instructions, "TimelineAddToModule"))
        add_to_module["moduleItems"]
      elsif (timeline_module = entries_by_type(timeline_add_entries, "TimelineTimelineModule")).any?
        timeline_module.filter_map { |content| content["items"] }.flatten
      else
        []
      end
    end

    def instruction_by_type(instructions, type)
      instructions.find { |instruction| instruction["type"] == type }
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

    def expand_description(tweet)
      range = tweet["display_text_range"]
      description = if range[0] == range[1]
                      ""
                    else
                      tweet["full_text"][range[0]..range[1]]
                    end

      # Ensure replacements get processed right to left
      tweet["entities"]["urls"].sort { |a, b| b["indices"][0] - a["indices"][0] }.each do |entry|
        indices = entry["indices"]
        new_link_start = indices[0] - range[0]
        new_link_end = indices[1] - range[0]
        description[new_link_start..new_link_end] = entry["expanded_url"]
      end
      # Remove link to the tweet itself
      if (media = tweet["extended_entities"]["media"].first)
        description = description.remove(media["url"])
      end
      description.strip
    end

    def make_request(url, params)
      fetch_json("#{API_BASE_URL}/#{url}", params: params.transform_values(&:to_json), headers: api_headers)
    end

    def tokens
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://twitter.com/i/flow/login"

        driver.wait_for_element(css: "input[autocomplete='username']").send_keys Config.twitter_user
        driver.find_element(xpath: "//*[text()='Next']").click

        driver.wait_for_element(css: "input[type='password']").send_keys Config.twitter_pass
        driver.find_element(xpath: "//*[text()='Log in']").click

        if Config.twitter_otp_secret.present?
          otp = ROTP::TOTP.new(Config.twitter_otp_secret).now
          driver.wait_for_element(css: "input").send_keys otp
          driver.find_element(xpath: "//*[text()='Next']").click
        end

        # The auth_token cookie isn't available immediately, so wait a bit
        auth_token = driver.wait_for_cookie("auth_token")
        csrf_token = driver.cookie_value("ct0")
        [auth_token, csrf_token]
      end
    end
    cache(:tokens, 55.minutes)

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
