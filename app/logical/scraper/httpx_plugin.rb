module Scraper
  module HttpxPlugin
    module InstanceMethods
      delegate :scraper, to: :@options

      def request(method, uri, should_raise: true, **params)
        response = scraper.enfore_rate_limit { super(method, uri, **params) }

        headers = @options.headers.merge(params[:headers] || {}).to_h
        relevant_options = params.slice(:params, :json, :form, :body)
        relevant_options[:headers] = headers if headers.present?
        scraper.log_response(response.uri, method, relevant_options, response.status, response.body.to_s)

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
      def option_scraper(value)
        value
      end
    end
  end
end
