module Sites
  module Definitions
    module Discord
      module_function

      def enum_value
        "discord"
      end

      def display_name
        "Discord"
      end

      def homepage
        "https://discord.com/"
      end

      def gallery_templates
        [
          "discord.com/invite/{site_artist_identifier}",
          "discord.gg/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,25}/
      end
    end
  end
end
