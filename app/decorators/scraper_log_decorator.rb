class ScraperLogDecorator < ApplicationDecorator
  def preview
    lines = []
    lines << "#{request['method'].upcase}: #{request['path']}"
    if (query_params = request.dig("request_params", "params"))
      lines << "?#{CGI.unescape(query_params.to_query)}"
    end
    if (body_params = formatted_body_params)
      lines << "body: #{body_params}"
    end
    h.safe_join(lines.map { |line| h.tag.div(line) })
  end

  def formatted_body_params
    body_params = request["request_params"]&.values_at("body", "json", "form")&.find(&:itself)
    body_params.is_a?(Hash) ? body_params.to_query : body_params
  end

  def full_text
    remaining_params = request.except("response_body")
    remaining_json = JSON.pretty_generate(remaining_params)
    h.safe_join([
      h.tag.pre(remaining_json),
      h.tag.pre(pretty_response.html_safe),
    ])
  end

  def response_as_json
    JSON.parse(request["response_body"])
  rescue JSON::ParserError
    # Do nothing
  end

  def pretty_response
    inline_formatter = Rouge::Formatters::HTMLInline.new("molokai")
    if (json = response_as_json)
      Rouge.highlight(JSON.pretty_generate(json), Rouge::Lexers::JSON, inline_formatter)
    else
      Rouge.highlight(request["response_body"], Rouge::Lexers::HTML, inline_formatter)
    end
  end
end
