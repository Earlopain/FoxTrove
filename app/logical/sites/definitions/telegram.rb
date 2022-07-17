# frozen_string_literal: true

module Sites
  module Definitions
    class Telegram < SimpleDefinition
      def enum_value
        "telegram"
      end

      def display_name
        "Telegram"
      end

      def homepage
        "https://telegram.org/"
      end

      def gallery_templates
        [
          "t.me/{site_artist_identifier}",
          "telegram.me/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{5,64}/
      end
    end
  end
end
