class Site < ApplicationRecord
  has_many :artist_urls, inverse_of: :site
  has_many :artists, through: :artist_urls
  has_many :submissions, through: :artist_urls

  def artist_url_identifier_templates
    artist_url_templates.map do |template|
      Addressable::Template.new template
    end
  end

  def matching_template_and_result(uri)
    artist_url_identifier_templates.each do |template|
      matches = template.extract uri, IdentifierProcessor
      return { template: template, site_artist_identifier: matches["site_artist_identifier"] } if matches
    end
    nil
  end
end

class IdentifierProcessor
  def self.match(name)
    return /https?/ if name == "https"
    return /(www\.)?/ if name == "www"
    return /((old|new|www)\.)?/ if name == "reddit_old_new_www"
    return /[a-zA-Z0-9_\-.~]*/ if name == "site_artist_identifier"

    raise StandardError "Unhandled matcher #{name}"
  end
end
