# frozen_string_literal: true

module Scraper
  class Pawoo < MastodonV1
    def self.enabled?
      Config.pawoo_access_token.present?
    end

    def domain
      "pawoo.net"
    end

    def access_token
      Config.pawoo_access_token
    end
  end
end
