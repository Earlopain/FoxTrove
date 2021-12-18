class UrlParser
  def self.parse(url)
    uri = Addressable::URI.parse url
    Site.find_each.each do |site|
      match = matching_template_and_result site, uri
      match[:site] = site if match
      match[:identifier_valid] = Regexp.new("^#{site.artist_identifier_regex}$").match? match[:site_artist_identifier] if match
      return match if match
    end
    nil
  end

  def self.matching_template_and_result(site, uri)
    artist_url_identifier_templates(site).each do |template|
      matches = template.extract uri, IdentifierProcessor
      return { template: template, site_artist_identifier: matches["site_artist_identifier"] } if matches
    end
    nil
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
    return /[^\/?&#]*/ if name == "site_artist_identifier"
    return /.*?/ if name == "remaining"

    raise StandardError, "Unhandled matcher #{name}"
  end
end
