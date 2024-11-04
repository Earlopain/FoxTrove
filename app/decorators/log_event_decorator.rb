class LogEventDecorator < ApplicationDecorator
  def preview
    case action
    when "scraper_request"
      lines = []
      lines << "#{payload['method'].upcase}: #{payload['path']}"
      if (query_params = payload.dig("request_params", "params"))
        lines << "?#{CGI.unescape(query_params.to_query)}"
      end
      if (body_params = formatted_body_params)
        lines << "body: #{body_params}"
      end
      h.safe_join(lines.map { |line| h.tag.div(line) })
    else
      "Unknown action #{action}"
    end
  end

  def formatted_body_params
    body_params = payload["request_params"]&.values_at("body", "json", "form")&.find(&:itself)
    body_params.is_a?(Hash) ? body_params.to_query : body_params
  end

  def full_text
    case action
    when "scraper_request"
      remaining_params = payload.except("response_body")
      remaining_json = JSON.pretty_generate(remaining_params)
      h.safe_join([
        h.tag.pre(remaining_json),
        h.tag.pre(pretty_response.html_safe),
      ])
    else
      "Unknown action #{action}"
    end
  end

  concerning :ScraperRequest do
    def response_as_json
      JSON.parse(payload["response_body"])
    rescue JSON::ParserError
      # Do nothing
    end

    def pretty_response
      inline_formatter = Rouge::Formatters::HTMLInline.new("molokai")
      if (json = response_as_json)
        Rouge.highlight(JSON.pretty_generate(json), Rouge::Lexers::JSON, inline_formatter)
      else
        Rouge.highlight(payload["response_body"], Rouge::Lexers::HTML, inline_formatter)
      end
    end
  end
end
