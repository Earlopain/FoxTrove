module Sites
  class IdentifierProcessor
    def self.match(name)
      return /^(https?:\/\/)?(www\.)?/ if name == "prefix"
      return /((old|new)\.)?/ if name == "reddit_old_new"
      return /(sfw\.)?/ if name == "furaffinity_sfw"
      return /[a-zA-Z]{2}\/|^$/ if name == "pixiv_lang"
      return /[^\/?&#]*/ if name == "site_artist_identifier"
      return /.*?/ if name == "remaining"

      raise StandardError, "Unhandled matcher #{name}"
    end
  end
end
