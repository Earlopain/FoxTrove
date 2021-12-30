module Sites
  class SimpleDefinition
    delegate :enum_value, :display_name, :homepage, to: :@definition
    attr_accessor :image_domains, :download_headers

    def initialize(definition)
      @definition = definition
      @image_domains = definition.respond_to?(:image_domains) ? Array.wrap(definition.image_domains) : []
      @download_headers = definition.respond_to?(:download_headers) ? definition.download_headers : {}
      @gallery_templates = Array.wrap(definition.gallery_templates).map { |t| Addressable::Template.new("{prefix}#{t}{/remaining}{?remaining}{#remaining}") }
      @can_match_if_contains = Array.wrap(definition.gallery_templates).map { |t| t.gsub(/{[^)]*}/, "") }
      @username_identifier_regex = Regexp.new("^#{definition.username_identifier_regex}$")
    end

    def match_for(uri)
      extracted = @gallery_templates.lazy.filter_map do |template|
        next if @can_match_if_contains.filter { |a| uri.to_s.include? a }.none?

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
    def handles_domain?(domain)
      @image_domains.include? domain
    end

    def icon_class
      "site-icon-#{enum_value.starts_with?('youtube') ? 'youtube' : enum_value}"
    end

    def gallery_url(identifier)
      "https://#{@gallery_templates.first.expand(site_artist_identifier: identifier)}"
    end
  end
end
