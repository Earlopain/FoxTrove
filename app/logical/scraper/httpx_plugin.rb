# frozen_string_literal: true

module Scraper
  module HttpxPlugin
    module InstanceMethods
      delegate :scraper, to: :@options

      def request(method, uri, **params)
        response = scraper.enfore_rate_limit { super }
        scraper.log_response(uri, method, params, response.status, response.body.to_s)
        raise_if_response_not_ok(response)
        response
      end

      def fetch_html(path, method: :get, **params)
        response = send(method, path, **params)
        Nokogiri::HTML(response.body.to_s)
      end

      def fetch_json(path, method: :get, **params)
        response = send(method, path, **params)
        JSON.parse(response.body.to_s)
      end

      private

      def raise_if_response_not_ok(response)
        raise HTTPX::HTTPError, response if response.status != 200
      end
    end

    module OptionsMethods
      def option_scraper(value)
        value
      end
    end
  end
end
