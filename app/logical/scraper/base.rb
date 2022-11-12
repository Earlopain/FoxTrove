# frozen_string_literal: true

module Scraper
  class Base
    delegate :url_identifier, :api_identifier, to: :@artist_url
    def initialize(artist_url)
      @artist_url = artist_url.is_a?(Integer) ? ArtistUrl.find(artist_url) : artist_url
      @has_more = true
      @previous_request = 0
    end

    # Anything the scraper needs to initialize itself, like
    # fetching a session token
    def init
      # Overwrite this in the scraper
    end

    def site_enum
      self.class.name.demodulize.underscore
    end

    # Will there possibly be more results when calling fetch_next_batch
    def more?
      @has_more
    end

    def end_reached
      @has_more = false
    end

    # Make a network request to the service and get an array of entries.
    # Can also return an emptry arrray, scraping is only stopped once end_reached
    # is called.
    def fetch_next_batch
      raise NotImplementedError
    end

    def fetch_and_save_next_submissions
      fetch_next_batch.map do |api_submission|
        submission = to_submission(api_submission)
        submission.save(@artist_url)
        submission
      end
    end

    # Convert the entries from fetch_next_batch into something generic
    def to_submission
      raise NotImplementedError
    end

    # Converts the user-facing value into something that is more permanent.
    # Might be the same, but most sites use a permanent numeric identifier.
    # Used to prevent duplicate accounts in cases where they can be renamed.
    def fetch_api_identifier
      raise NotImplementedError
    end

    def log_response(path, method, request_params, status_code, body)
      return unless Config.log_scraper_requests?

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

    def fetch_html(path, method = :get, **params)
      response = enfore_rate_limit do
        HTTParty.send(method, path, params)
      end
      log_response(path, method, params, response.code, response.body)
      response
    end

    def fetch_json(path, method = :get, **params)
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
  end
end
