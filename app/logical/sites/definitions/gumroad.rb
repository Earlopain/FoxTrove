# frozen_string_literal: true

module Sites
  module Definitions
    class Gumroad < SimpleDefinition
      def enum_value
        "gumroad"
      end

      def display_name
        "Gumroad"
      end

      def homepage
        "https://gumroad.com/"
      end

      def gallery_templates
        [
          "{site_artist_identifier}.gumroad.com",
          "gumroad.com/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,20}/
      end
    end
  end
end
