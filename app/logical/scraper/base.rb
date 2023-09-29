# frozen_string_literal: true

module Scraper
  class Base
    delegate :url_identifier, :api_identifier, to: :@artist_url
    def initialize(artist_url)
      @artist_url = artist_url.is_a?(Integer) ? ArtistUrl.find(artist_url) : artist_url
      @has_more = true
      @previous_request = 0
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
      instance_variable_get(:"@#{self.class.state}")
    end

    # Insert the value where the scraper should continue from in case of an error
    def jumpstart(value)
      instance_variable_set(:"@#{self.class.state}", value)
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

      alias_method "#{method_name}_old", method_name
      define_method(method_name) do
        key = self.class.cache_key(method_name)
        return Rails.cache.fetch(key) if Rails.cache.exist?(key)

        value = send("#{method_name}_old")
        Rails.cache.write(key, value, expires_in: expires_in) if value # Don't cache nil
        value
      end
    end

    def self.delete_cache(method_name)
      Rails.cache.delete(cache_key(method_name))
    end

    def self.cache_key(method_name)
      config_checksum = Digest::MD5.hexdigest(required_config_keys.map { |key| Config.send(key) }.join)
      "#{name}.#{method_name}/#{config_checksum}"
    end

    def self.cached_methods
      @_cached_methods || []
    end

    protected

    def end_reached
      @has_more = false
    end

    # Convert the entries from fetch_next_batch into something generic
    def to_submission
      raise NotImplementedError
    end

    def fetch_html(path, method: :get, **params)
      response = enfore_rate_limit do
        HTTParty.send(method, path, params)
      end
      log_response(path, method, params, response.code, response.body)
      response
    end

    def fetch_json(path, method: :get, **params)
      response = enfore_rate_limit do
        HTTParty.send(method, path, { format: :json, **params })
      end
      log_response(path, method, params, response.code, response.body)
      response
    end

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

    private

    def log_response(path, method, request_params, status_code, body)
      return unless Config.log_scraper_requests?

      @artist_url.add_log_event(:scraper_request, {
        path: path,
        method: method,
        request_params: {
          **request_params,
        },
        response_code: status_code,
        response_body: body.encode(body.encoding, body.encoding, invalid: :replace),
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
