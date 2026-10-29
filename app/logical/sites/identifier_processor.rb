module Sites
  class IdentifierProcessor
    attr_reader :invalid_identifier, :username_identifier, :api_identifier

    def initialize(username_identifier_regex, api_identifier_regex)
      @username_identifier_regex = username_identifier_regex
      @api_identifier_regex = api_identifier_regex
    end

    def match(name)
      return %r{^(https?://)?(www\.)?} if name == "prefix"
      return /((old|new)\.)?/ if name == "reddit_old_new"
      return /(sfw\.)?/ if name == "furaffinity_sfw"
      return %r{[a-zA-Z]{2}/|^$} if name == "pixiv_lang"
      return %r{[^/?&#]*} if %w[site_artist_identifier site_artist_api_identifier segment].include?(name)
      return /.*?/ if name == "remaining"

      raise StandardError, "Unhandled matcher #{name}"
    end

    def restore(name, value)
      case name
      when "site_artist_identifier"
        if value.match?(@username_identifier_regex)
          @username_identifier = value
        else
          @invalid_identifier = value
        end
      when "site_artist_api_identifier"
        if value.match?(@api_identifier_regex)
          @api_identifier = value
        else
          @invalid_identifier = value
        end
      end
      value
    end
  end
end
