module Scraper
  class Base
    def initialize(identifier:, stop_marker:)
      @identifier = identifier
      @stop_marker = stop_marker
      @has_more = true
    end

    # Anything the scraper needs to initialize itself, like
    # fetching a session token
    def init
    end

    # Will there possibly be more results when calling fetch_next_batch
    def more?
      @has_more
    end

    def end_reached
      @has_more = false
    end

    def enabled?
      raise NotImplementedError
    end

    # Make a network request to the service and get an array of entries.
    # Can also return an emptry arrray, scraping is only stopped once end_reached
    # is called.
    def fetch_next_batch
      raise NotImplementedError
    end

    # Convert the entries from fetch_next_batch into something generic
    def to_submission
      raise NotImplementedError
    end
  end
end
