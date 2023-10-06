# frozen_string_literal: true

module Sites
  class SimpleDefinition
    attr_reader :site_type, :display_name, :homepage, :gallery_templates, :username_identifier_regex, :image_domains, :download_headers

    def initialize(definition_data)
      @site_type = definition_data["enum_value"]
      @display_name = definition_data["display_name"]
      @homepage = definition_data["homepage"]
      @gallery_templates = definition_data["gallery_templates"].map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @username_identifier_regex = Regexp.new("^#{definition_data['username_identifier_regex']}$")
      @image_domains = []
      @download_headers = {}
    end

    def match_for_gallery(uri)
      extracted_identifiers = gallery_templates.filter_map do |template|
        template.extract(uri, IdentifierProcessor)&.dig("site_artist_identifier")
      end
      return if extracted_identifiers.none?

      first_valid_identifier = extracted_identifiers.find { |identifier| username_identifier_regex.match?(identifier) }
      return { identifier: first_valid_identifier, valid: true } if first_valid_identifier

      { identifier: extracted_identifiers.first, valid: false }
    end

    # Returns true when the site needs special headers to download from
    def handles_image_domain?(domain)
      image_domains.include? domain
    end

    def icon_class
      "site-icon-#{site_type.starts_with?('youtube') ? 'youtube' : site_type}"
    end

    def gallery_url(identifier)
      "https://#{gallery_templates.first.expand(site_artist_identifier: identifier)}"
    end

    def missing_config_keys
      []
    end

    def cached_values
      {}
    end

    def manually_disabled?
      false
    end

    def scraper_enabled?
      false
    end
  end
end
