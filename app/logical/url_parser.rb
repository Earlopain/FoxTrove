class UrlParser
  def self.parse(url)
    uri = Addressable::URI.parse url
    Site.find_each.lazy.filter_map do |site|
      identifier = get_match_for_site(site, uri)
      next unless identifier

      {
        identifier: identifier,
        identifier_valid: Regexp.new("^#{site.artist_identifier_regex}$").match?(identifier),
        site: site,
      }
    end.first
  end

  def self.get_match_for_site(site, uri)
    artist_url_identifier_templates(site).lazy.filter_map do |template|
      template.extract(uri, IdentifierProcessor).try(:[], "site_artist_identifier")
    end.first
  end

  def self.artist_url_identifier_templates(site)
    site.artist_url_templates.map do |template|
      Addressable::Template.new "{prefix}#{template}{/remaining}{?remaining}{#remaining}"
    end
  end
end

class IdentifierProcessor
  def self.match(name)
    return /^(https?:\/\/)?(www\.)?/ if name == "prefix"
    return /((old|new)\.)?/ if name == "reddit_old_new"
    return /[a-zA-Z]{2}\/|^$/ if name == "pixiv_lang"
    return /[^\/?&#]*/ if name == "site_artist_identifier"
    return /.*?/ if name == "remaining"

    raise StandardError, "Unhandled matcher #{name}"
  end
end
