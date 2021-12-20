module Sites
  class Definition
    attr_reader :enum_value, :display_name, :homepage

    def initialize(enum_value:, display_name:, homepage:, gallery_templates:,
                   username_identifier_regex:, submission_template: nil, supports_scraping: false)
      @enum_value = enum_value
      @display_name = display_name
      @homepage = homepage
      @gallery_template_string = gallery_templates.first
      @gallery_templates = gallery_templates.map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @username_identifier_regex = Regexp.new("^#{username_identifier_regex}$")
      @submission_template = Addressable::Template.new(submission_template) if supports_scraping
      @supports_scraping = supports_scraping
    end

    def supports_scraping?
      @supports_scraping
    end

    def match_for(uri)
      extracted = @gallery_templates.filter_map do |template|
        template.extract(uri, Definitions::IdentifierProcessor)
      end.first
      return unless extracted

      {
        identifier: extracted["site_artist_identifier"],
        identifier_valid: @username_identifier_regex.match?(extracted["site_artist_identifier"]),
        site: self,
      }
    end

    def icon_path
      filename = enum_value.starts_with?("youtube") ? "youtube" : enum_value
      "/icons/#{filename}.png"
    end

    def gallery_url(identifier)
      Addressable::Template.new("https://#{@gallery_template_string}")
                           .expand(site_artist_identifier: identifier).to_s
    end
  end
end
