# frozen_string_literal: true

module Sites
  module Definitions
    class Ychart < SimpleDefinition
      def enum_value
        "ychart"
      end

      def display_name
        "YCH.art"
      end

      def homepage
        "https://ych.art/"
      end

      def gallery_templates
        [
          "ych.art/user/{site_artist_identifier}",
          "ych.art/user/{site_artist_identifier}/portfolio",
          "ych.art/user/{site_artist_identifier}/about"
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{1,20}/
      end
    end
  end
end
