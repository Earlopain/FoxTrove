module Sites
  class SimpleDefinition
    attr_reader :site_type, :display_name, :homepage, :download_headers

    def initialize(definition_data)
      @site_type = definition_data["enum_value"]
      @display_name = definition_data["display_name"]
      @homepage = definition_data["homepage"]
      @gallery_templates = definition_data["gallery_templates"].map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @username_identifier_regex = Regexp.new("^#{definition_data['username_identifier_regex']}$")
      @api_identifier_regex = Regexp.new("^#{definition_data['api_identifier_regex']}$")
      @submission_template = Addressable::Template.new(definition_data["submission_template"]) if definition_data["submission_template"]
      @image_domains = definition_data["image_domains"] || []
      @download_headers = definition_data["download_headers"] || {}
    end

    def match_for_gallery(uri)
      processor = IdentifierProcessor.new(@username_identifier_regex, @api_identifier_regex)
      @gallery_templates.each do |template|
        template.extract(uri, processor)

        return { type: :username, identifier: processor.username_identifier } if processor.username_identifier
        return { type: :api,      identifier: processor.api_identifier } if processor.api_identifier
      end
      { type: :invalid, identifier: processor.invalid_identifier } if processor.invalid_identifier
    end

    # Returns true when the site needs special headers to download from
    def handles_image_domain?(domain)
      @image_domains.include? domain
    end

    def gallery_url(artist_url)
      expanded = @gallery_templates.first.expand(
        site_artist_identifier: artist_url.unescaped_url_identifier,
        site_artist_api_identifier: artist_url.api_identifier,
      )
      "https://#{expanded}"
    end

    def submission_url(submission)
      @submission_template.expand(
        site_artist_identifier: submission.artist_url.url_identifier,
        site_artist_api_identifier: submission.artist_url.api_identifier,
        site_submission_identifier: submission.identifier_on_site,
      ).to_s
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

    def scraper?
      false
    end
  end
end
