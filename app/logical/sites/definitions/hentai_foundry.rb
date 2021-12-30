module Sites
  module Definitions
    module HentaiFoundry
      module_function

      def enum_value
        "hentai_foundry"
      end

      def display_name
        "Hentai Foundry"
      end

      def homepage
        "https://www.hentai-foundry.com/"
      end

      def gallery_templates
        [
          "www.hentai-foundry.com/user/{site_artist_identifier}",
          "www.hentai-foundry.com/pictures/user/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9\-]{1,35}/
      end
    end
  end
end
