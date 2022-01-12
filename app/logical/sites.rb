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

  def download_file(outfile, uri, definition = nil)
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
  ].map { |definition| ScraperDefinition.new definition }.freeze

  SIMPLE = [
    Definitions::Sofurry,
    Definitions::Patreon,
    Definitions::Pixiv,
    Definitions::Weasyl,
    Definitions::Tumblr,
    Definitions::Newgrounds,
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
    Definitions::Furrynetwork,
  ].map { |definition| SimpleDefinition.new definition }.freeze

  ALL = (SCRAPERS + SIMPLE).freeze

  ENUM_MAP = ALL.to_h { |definition| [definition.enum_value, definition] }
end
