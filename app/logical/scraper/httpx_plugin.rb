# frozen_string_literal: true

module Scraper
  module HttpxPlugin
    module InstanceMethods
      delegate :scraper, to: :@options

      def request(method, uri, should_raise: true, **params)
        response = scraper.enfore_rate_limit { super(method, uri, **params) }

        request_options = response.instance_variable_get(:@request).options.to_hash
        relevant_options = request_options.slice(:headers, :params, :json, :form, :body)
        relevant_options.delete(:headers) if relevant_options[:headers].to_h.blank?
        scraper.log_response(response.uri, method, relevant_options, response.status, response.body.to_s)

        raise_if_response_not_ok(response) if should_raise
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
