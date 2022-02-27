module Scraper
  class Base
    def initialize(identifier:, api_identifier:)
      @identifier = identifier
      @api_identifier = api_identifier
      @has_more = true
    end

    # Anything the scraper needs to initialize itself, like
    # fetching a session token
    def init
    end

    def site_enum
      self.class.name.demodulize.underscore
    end

    # Will there possibly be more results when calling fetch_next_batch
    def more?
      @has_more
    end

    def end_reached
      @has_more = false
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

    # Used to check if the end was reached when scraping already happened
    def extract_timestamp_from_submission
      raise NotImplementedError
    end

    # Converts the user-facing value into something that is more permanent.
    # Might be the same, but most sites use a permanent numeric identifier.
    # Used to prevent duplicate accounts in cases where they can be renamed.
    def fetch_api_identifier
      raise NotImplementedError
    end
  end
end
