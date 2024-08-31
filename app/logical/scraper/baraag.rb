module Scraper
  class Baraag < MastodonV1
    def domain
      "baraag.net"
    end

    def access_token
      Config.baraag_access_token
    end
  end
end
