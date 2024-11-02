module Scraper
  class Base
    FRIENDLY_USER_AGENT = "FoxTrove/0.1 (by earlopain)"

    delegate :url_identifier, :api_identifier, to: :@artist_url
    attr_accessor :client

    def initialize(artist_url)
      @artist_url = artist_url.is_a?(Integer) ? ArtistUrl.find(artist_url) : artist_url
      @has_more = true
      @previous_request = 0
      @client = extend_client(HTTPX.plugin(HttpxPlugin, scraper: self))
    end

    def self.site_type
      name.demodulize.underscore
    end

    def self.all_config_keys
      Config.default_config.keys.select { |key| key.start_with?("#{site_type}_") }
    end

    def self.optional_config_keys
      const_defined?(:OPTIONAL_CONFIG_KEYS) ? self::OPTIONAL_CONFIG_KEYS : []
    end

    def self.required_config_keys
      all_config_keys - optional_config_keys - [:"#{site_type}_disabled?"]
    end

    def process!
      jumpstart(@artist_url.scraper_status[self.class::STATE.to_s]) if @artist_url.scraper_status.present?
      @artist_url.scraper_status["started_at"] ||= Time.current

      while more?
        submissions = fetch_and_save_next_submissions

        @artist_url.update(scraper_status: @artist_url.scraper_status.merge(self.class::STATE => state_value))

        break if submissions.any? { |submission| @artist_url.scraper_stop_marker&.after?(submission.timestamp_for_cutoff) }
      end
      @artist_url.update(
        last_scraped_at: @artist_url.scraper_status["started_at"],
        scraper_stop_marker: new_stop_marker,
        scraper_status: {},
      )
    end

    # Will there possibly be more results when calling fetch_next_batch
    def more?
      @has_more
    end

    # Make a network request to the service and get an array of entries.
    # Can also return an emptry arrray, scraping is only stopped once end_reached
    # is called.
    def fetch_next_batch
      raise NotImplementedError
    end

    # Value that describes the progress during scraping. Can be a page/offset/cursor etc.
    def state_value
      instance_variable_get(:"@#{self.class::STATE}")
    end

    # Insert the value where the scraper should continue from in case of an error
    def jumpstart(value)
      instance_variable_set(:"@#{self.class::STATE}", value)
    end

    # Which date should already be considered scraped? Normally this is good to set to
    # when the scrape started but some sites may exhibit a delay with indexing, resulting
    # in images being missed. See https://github.com/Earlopain/FoxTrove/issues/113
    def new_stop_marker
      @artist_url.scraper_status["started_at"]
    end

    def fetch_and_save_next_submissions
      fetch_next_batch.map do |api_submission|
        submission = to_submission(api_submission)
        submission.save(@artist_url)
        submission
      end
    end

    # Converts the user-facing value into something that is more permanent.
    # Might be the same, but most sites use a permanent numeric identifier.
    # Used to prevent duplicate accounts in cases where they can be renamed.
    def fetch_api_identifier
      raise NotImplementedError
    end

    def self.cache(method_name, expires_in)
      raise ArgumentError, "#{method_name} must have arity == 0" unless instance_method(method_name).arity == 0

      @_cached_methods ||= []
      @_cached_methods << method_name

      alias_method :"#{method_name}_old", method_name
      define_method(method_name) do
        key = self.class.cache_key(method_name)
        return Rails.cache.fetch(key) if Rails.cache.exist?(key)

        value = send(:"#{method_name}_old")
        Rails.cache.write(key, value, expires_in: expires_in) if value # Don't cache nil
        value
      end
    end

    def self.delete_cache(method_name)
      Rails.cache.delete(cache_key(method_name))
    end

    def self.cache_key(method_name)
      keys = required_config_keys + optional_config_keys
      config_checksum = Digest::MD5.hexdigest(keys.map { |key| Config.send(key) }.join("|"))
      "#{name}.#{method_name}/#{config_checksum}"
    end

    def self.cached_methods
      @_cached_methods || []
    end

    def end_reached
      @has_more = false
    end

    # Convert the entries from fetch_next_batch into something generic
    def to_submission
      raise NotImplementedError
    end

    # Add more plugins, set default headers, etc.
    def extend_client(client)
      client
    end

    delegate :fetch_json, :fetch_html, to: :@client

    def fetch_json_selenium(path)
      SeleniumWrapper.driver do |d|
        enfore_rate_limit do
          d.navigate.to path
        end
        begin
          text = d.find_element(css: "pre").text
          log_response(path, :get, {}, -1, text)
          JSON.parse(text)
        rescue Selenium::WebDriver::Error::NoSuchElementError
          raise JSON::ParserError, "#{path}: No response"
        end
      end
    end

    def log_response(path, method, request_params, status_code, body)
      return unless Config.log_scraper_requests?

      if body.encoding == Encoding::BINARY
        body = body.force_encoding(Encoding::UTF_8)
      end
      body = body.encode(body.encoding, body.encoding, invalid: :replace) unless body.valid_encoding?

      @artist_url.add_log_event(:scraper_request, {
        path: path,
        method: method,
        request_params: {
          **request_params,
        },
        response_code: status_code,
        response_body: body,
      })
    end

    # This is pretty hacky and only works because there is only one job executing at once
    def enfore_rate_limit(&)
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      elapsed_time = now - @previous_request
      if elapsed_time < Config.scraper_request_rate_limit
        sleep Config.scraper_request_rate_limit - elapsed_time
      end
      result = yield
      @previous_request = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result
    end
  end
end
