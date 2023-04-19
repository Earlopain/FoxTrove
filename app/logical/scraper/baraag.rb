# frozen_string_literal: true

module Scraper
  class Baraag < MastodonV1
    def self.required_config_keys
      %i[baraag_access_token]
    end

    def domain
      "baraag.net"
    end

    def access_token
      Config.baraag_access_token
    end
  end
end
