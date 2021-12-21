module Scraper
  class Twitter
    attr_reader :artist_url

    def initialize(artist_url)
      @artist_url = artist_url
    end
  end
end
