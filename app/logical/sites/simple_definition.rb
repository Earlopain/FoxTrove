# frozen_string_literal: true

module Sites
  class SimpleDefinition
    attr_reader :enum_value, :display_name, :homepage, :gallery_templates, :username_identifier_regex, :image_domains, :download_headers

    def initialize(definition_data)
      @enum_value = definition_data["enum_value"]
      @display_name = definition_data["display_name"]
      @homepage = definition_data["homepage"]
      @gallery_templates = definition_data["gallery_templates"].map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @username_identifier_regex = Regexp.new("^#{definition_data['username_identifier_regex']}$")
      @image_domains = []
      @download_headers = {}
    end

    def match_for_gallery(uri)
      extracted = gallery_templates.lazy.filter_map do |template|
        template.extract(uri, IdentifierProcessor)
      end.first
      return unless extracted

      {
        identifier: extracted["site_artist_identifier"],
        identifier_valid: username_identifier_regex.match?(extracted["site_artist_identifier"]),
        site: self,
      }
    end

    # Returns true when the site needs special headers to download from
    def handles_image_domain?(domain)
      image_domains.include? domain
    end

    def icon_class
      "site-icon-#{enum_value.starts_with?('youtube') ? 'youtube' : enum_value}"
    end

    def gallery_url(identifier)
      "https://#{gallery_templates.first.expand(site_artist_identifier: identifier)}"
    end
  end
end
