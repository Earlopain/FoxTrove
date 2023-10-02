# frozen_string_literal: true

module Sites
  module_function

  def from_enum(value)
    definitions.find { |definition| definition.enum_value == value }
  end

  def from_gallery_url(url)
    begin
      uri = Addressable::URI.parse url
    rescue Addressable::URI::InvalidURIError
      return nil
    end

    definitions.each do |definition|
      match = definition.match_for_gallery(uri)
      return match.merge(site: definition) if match
    end
    nil
  end

  def download_headers_for_image_uri(uri)
    definition = definitions.find do |d|
      d.handles_image_domain? uri.domain
    end
    definition&.download_headers || {}
  end

  def download_file(outfile, url)
    fixed_uri = fix_url(url)
    headers = download_headers_for_image_uri(fixed_uri)
    response = HTTParty.get(fixed_uri, headers: headers) do |fragment|
      next if [301, 302].include?(fragment.code)

      outfile.write(fragment)
    end
    outfile.rewind
    response
  end

  def fix_url(url)
    unencoded = Addressable::URI.unencode(url)
    escaped = Addressable::URI.escape(unencoded)
    uri = Addressable::URI.parse(escaped)
    uri.scheme = "https" unless uri.scheme
    raise Addressable::URI::InvalidURIError, "scheme must be http(s)" unless uri.scheme.in?(%w[http https])
    raise Addressable::URI::InvalidURIError, "host must be set" if uri.host.blank?

    uri
  end

  def definitions
    @definitions ||= Rails.root.glob("app/logical/sites/definitions/*.yml").map do |file_path|
      data = Psych.safe_load_file(file_path)
      Sites.const_get(data["type"]).new(data.except("type"))
    end
  end

  def scraper_definitions
    definitions.select { |s| s.is_a?(ScraperDefinition) }
  end

  def reset_cache
    @definitions = nil
  end
end
