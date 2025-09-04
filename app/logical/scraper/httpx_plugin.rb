module Scraper
  module HttpxPlugin
    def self.from_scraper(scraper)
      HTTPX.plugin(
        HttpxPlugin,
        enforce_rate_limit: scraper.method(:enforce_rate_limit),
        log_response: scraper.method(:log_response),
      )
    end

    module InstanceMethods
      delegate :enforce_rate_limit, :log_response, to: :@options

      def request(method, uri, should_raise: true, **params)
        response = enforce_rate_limit.call { super(method, uri, **params) }

        headers = @options.headers.merge(params[:headers] || {}).to_h
        relevant_options = params.slice(:params, :json, :form, :body)
        relevant_options[:headers] = headers if headers.present?
        log_response.call(response.uri, method, relevant_options, response.status, response.body.to_s)

        response.raise_unless_ok if should_raise
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
    end

    module ResponseMethods
      def raise_unless_ok
        raise HTTPX::HTTPError, self if status < 200 || status > 299
      end
    end

    module OptionsMethods
      def option_enforce_rate_limit(value) = value
      def option_log_response(value) = value
    end
  end
end
