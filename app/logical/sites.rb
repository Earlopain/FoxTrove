module Sites
  DEFINITIONS_PATH = Rails.root.join("app/logical/sites/definitions")

  module_function

  def from_enum(value)
    definitions.find { |definition| definition.site_type == value }
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

  def download_file(url)
    fixed_uri = fix_url(url)
    headers = download_headers_for_image_uri(fixed_uri)
    response = HTTPX.plugin(:stream).plugin(:follow_redirects).with(headers: headers).get(fixed_uri, stream: true)
    outfile = Tempfile.new(binmode: true)
    response.each do |chunk|
      next if response.status == 301 || response.status == 302

      outfile.write(chunk)
    end
    outfile.rewind
    raise StandardError, "Failed to download #{url}: #{response.status}" if response.status != 200

    yield outfile
  ensure
    outfile&.unlink
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
    @definitions ||= DEFINITIONS_PATH.glob("*.yml").map do |file_path|
      data = Psych.safe_load_file(file_path)
      Sites.const_get(data["type"]).new(data.except("type"))
    end
  end

  def scraper_definitions
    definitions.select(&:scraper?)
  end
end
