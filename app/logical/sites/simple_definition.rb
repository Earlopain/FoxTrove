# frozen_string_literal: true

module Sites
  class SimpleDefinition
    def initialize
      @gallery_templates = Array.wrap(gallery_templates).map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @username_identifier_regex = Regexp.new("^#{username_identifier_regex}$")
    end

    def match_for_gallery(uri)
      extracted = @gallery_templates.lazy.filter_map do |template|
        template.extract(uri, IdentifierProcessor)
      end.first
      return unless extracted

      {
        identifier: extracted["site_artist_identifier"],
        identifier_valid: @username_identifier_regex.match?(extracted["site_artist_identifier"]),
        site: self,
      }
    end

    # Returns true when the site needs special headers to download from
    def handles_image_domain?(domain)
      image_domains.include? domain
    end

    def image_domains
      []
    end

    def download_headers
      {}
    end

    def icon_class
      "site-icon-#{enum_value.starts_with?('youtube') ? 'youtube' : enum_value}"
    end

    def gallery_url(identifier)
      "https://#{@gallery_templates.first.expand(site_artist_identifier: identifier)}"
    end
  end
end
