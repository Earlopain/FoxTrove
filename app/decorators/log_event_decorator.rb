# frozen_string_literal: true

class LogEventDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatedDecorator
  end

  delegate_all

  def preview
    case action
    when "scraper_request"
      lines = []
      lines << "#{payload['method'].upcase}: #{payload['path']}"
      if (query_params = payload.dig("request_params", "query"))
        lines << "?#{CGI.unescape(query_params.to_query)}"
      end
      if (body_params = payload.dig("request_params", "body"))
        lines << "body: #{body_params.is_a?(Hash) ? body_params.to_query : body_params}"
      end
      h.safe_join(lines.map { |line| h.tag.div(line) })
    else
      "Unknown action #{action}"
    end
  end

  def full_text
    case action
    when "scraper_request"
      remaining_params = payload.except("response_body")
      remaining_json = JSON.pretty_generate(remaining_params)
      h.safe_join([
        h.tag.pre(remaining_json),
        h.tag.pre(pretty_response),
      ])
    else
      "Unknown action #{action}"
    end
  end

  concerning :ScraperRequest do
    def response_is_json?
      JSON.parse(payload["response_body"])
      true
    rescue JSON::ParserError
      false
    end

    def pretty_response
      if response_is_json?
        JSON.pretty_generate(JSON.parse(payload["response_body"]))
      else
        Nokogiri::HTML(payload["response_body"]).to_xhtml(indent: 2)
      end
    end
  end
end
