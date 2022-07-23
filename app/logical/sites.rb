# frozen_string_literal: true

module Sites
  module_function

  def from_enum(value)
    ENUM_MAP[value]
  end

  def from_gallery_url(url)
    begin
      uri = Addressable::URI.parse url
    rescue Addressable::URI::InvalidURIError
      return nil
    end

    ALL.lazy.filter_map do |definition|
      definition.match_for_gallery uri
    end.first
  end

  def download_headers_for_image_uri(uri)
    definition = ALL.find do |d|
      d.handles_image_domain? uri.domain
    end
    definition&.download_headers || {}
  end

  def download_file(outfile, url)
    fixed_uri = fix_url(url)
    headers = download_headers_for_image_uri(fixed_uri)
    response = HTTParty.get(fixed_uri, { headers: headers }) do |chunk|
      outfile.write(chunk)
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

  ALL = Definitions.constants.map { |name| Definitions.const_get(name).new }

  ENUM_MAP = ALL.index_by(&:enum_value).freeze
end
