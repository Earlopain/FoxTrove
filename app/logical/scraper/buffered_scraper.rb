# frozen_string_literal: true

module Scraper
  # Some sites return many entries per page but fetching full data for these takes a long time.
  # Loading all entries just to see if something is new is bad. Buffer it instead, so that
  # the details for only one entry must be fetched.
  class BufferedScraper < Base
    def initialize(artist_url)
      super
      @buffer = []
      @will_have_more = true
      @after_first_request = false
    end

    def fetch_from_batch(&)
      if @buffer.empty?
        update_state if @after_first_request
        @buffer = yield
        @after_first_request = true
        @will_have_more = !@buffer.empty?
      end

      entry = @buffer.shift
      end_reached if @buffer.empty? && !@will_have_more
      entry
    end

    def update_state
      raise NotImplementedError
    end
  end
end
