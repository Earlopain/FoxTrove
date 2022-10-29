# frozen_string_literal: true

module Sites
  module Definitions
    class Toyhouse < SimpleDefinition
      def enum_value
        "toyhouse"
      end

      def display_name
        "Toyhouse"
      end

      def homepage
        "https://toyhou.se/"
      end

      def gallery_templates
        [
          "toyhou.se/{site_artist_identifier}",
          "toyhou.se/{site_artist_identifier}/art",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{1,50}/
      end

      def submission_template
        "https://toyhou.se/~images/{site_submission_identifier}"
      end
    end
  end
end
