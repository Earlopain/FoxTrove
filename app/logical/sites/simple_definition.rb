module Sites
  class SimpleDefinition
    attr_reader :enum_value, :display_name, :homepage

    def initialize(enum_value:, display_name:, homepage:, gallery_templates:,
                   username_identifier_regex:)
      @enum_value = enum_value
      @display_name = display_name
      @homepage = homepage
      @gallery_template_string = gallery_templates.first
      @gallery_templates = gallery_templates.map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @can_match_if_contains = gallery_templates.map { |t| t.gsub(/{[^)]*}/, "") }
      @username_identifier_regex = Regexp.new("^#{username_identifier_regex}$")
    end

    def match_for(uri)
      extracted = @gallery_templates.lazy.filter_map do |template|
        next if @can_match_if_contains.filter { |a| uri.to_s.include? a }.none?

        template.extract(uri, Definitions::IdentifierProcessor)
      end.first
      return unless extracted

      {
        identifier: extracted["site_artist_identifier"],
        identifier_valid: @username_identifier_regex.match?(extracted["site_artist_identifier"]),
        site: self,
      }
    end

    def icon_class
      "site-icon-#{enum_value.starts_with?('youtube') ? 'youtube' : enum_value}"
    end

    def gallery_url(identifier)
      Addressable::Template.new("https://#{@gallery_template_string}")
                           .expand(site_artist_identifier: identifier).to_s
    end
  end
end
