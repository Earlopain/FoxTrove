# frozen_string_literal: true

module Sites
  module Definitions
    module Twitch
      module_function

      def enum_value
        "twitch"
      end

      def display_name
        "Twitch"
      end

      def homepage
        "https://www.twitch.tv/"
      end

      def gallery_templates
        "twitch.tv/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{4,25}/
      end
    end
  end
end
