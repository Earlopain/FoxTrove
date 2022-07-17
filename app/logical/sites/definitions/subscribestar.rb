# frozen_string_literal: true

module Sites
  module Definitions
    class Subscribestar < SimpleDefinition
      def enum_value
        "subscribestar"
      end

      def display_name
        "SubscribeStar"
      end

      def homepage
        "https://www.subscribestar.com/"
      end

      def gallery_templates
        [
          "subscribestar.com/{site_artist_identifier}",
          "subscribestar.adult/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,512}/
      end
    end
  end
end
