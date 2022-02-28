module Sites
  module_function

  def from_enum(value)
    ENUM_MAP[value]
  end

  def from_url(url)
    begin
      uri = Addressable::URI.parse url
    rescue Addressable::URI::InvalidURIError
      return nil
    end

    ALL.lazy.filter_map do |definition|
      definition.match_for uri
    end.first
  end

  def for_domain(domain)
    ALL.lazy.filter do |definition|
      definition.handles_domain? domain
    end.first
  end

  def download_file(outfile, url, definition = nil)
    # produces the right uri for all of these:
    # https://d.furaffinity.net/art/peyzazhik/1629082282/1629082282.peyzazhik_%D0%B7%D0%B0%D0%BB%D0%B8%D0%B2%D0%B0%D1%82%D1%8C-%D0%B3%D0%B8%D1%82%D0%B0%D1%80%D1%83.jpg
    # https://d.furaffinity.net/art/peyzazhik/1629082282/1629082282.peyzazhik_заливать-гитару.jpg
    # https://d.furaffinity.net/art/nawka/1642391380/1642391380.nawka__sd__kwaza_and_hector_[final].jpg
    # https://d.furaffinity.net/art/fr95/1635001690/1635001679.fr95_co＠f-r9512.png  (notice the different @ sign)
    unencoded = Addressable::URI.unencode(url)
    escaped = Addressable::URI.escape(unencoded)
    uri = Addressable::URI.parse(escaped)
    # https://www.newgrounds.com/art/view/nawka/comm-soot-and-lunamew
    # Secondary image url is missing the scheme, just assume https in those cases
    uri.scheme = "https" unless uri.scheme
    raise Addressable::URI::InvalidURIError, "scheme must be http(s)" unless uri.scheme.in?(%w[http https])
    raise Addressable::URI::InvalidURIError, "host must be set" if uri.host.blank?

    definition ||= for_domain(uri.domain)
    headers = definition&.download_headers || {}
    response = HTTParty.get(uri, { headers: headers }) do |chunk|
      outfile.write(chunk)
    end
    outfile.rewind
    response
  end

  SCRAPERS = [
    Definitions::Twitter,
    Definitions::Inkbunny,
    Definitions::Deviantart,
    Definitions::Artstation,
    Definitions::Reddit,
    Definitions::Furaffinity,
    Definitions::Weasyl,
    Definitions::Newgrounds,
    Definitions::Furrynetwork,
    Definitions::Sofurry,
  ].map { |definition| ScraperDefinition.new definition }.freeze

  SIMPLE = [
    Definitions::Patreon,
    Definitions::Pixiv,
    Definitions::Tumblr,
    Definitions::Vk,
    Definitions::Instagram,
    Definitions::Subscribestar,
    Definitions::Kofi,
    Definitions::Discord,
    Definitions::Fanbox,
    Definitions::Linktree,
    Definitions::Carrd,
    Definitions::Telegram,
    Definitions::Twitch,
    Definitions::Picarto,
    Definitions::Gumroad,
    Definitions::Skeb,
    Definitions::Pawoo,
    Definitions::Baraag,
    Definitions::YoutubeChannel,
    Definitions::YoutubeLegacy,
    Definitions::YoutubeVanity,
    Definitions::Facebook,
    Definitions::HentaiFoundry,
    Definitions::Pillowfort,
    Definitions::Commishes,
  ].map { |definition| SimpleDefinition.new definition }.freeze

  ALL = (SCRAPERS + SIMPLE).freeze

  ENUM_MAP = ALL.to_h { |definition| [definition.enum_value, definition] }
end
