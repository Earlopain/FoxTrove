# frozen_string_literal: true

module Sites
  module Definitions
    class Deviantart < ScraperDefinition
      def enum_value
        "deviantart"
      end

      def display_name
        "DeviantArt"
      end

      def homepage
        "https://www.deviantart.com"
      end

      def gallery_templates
        [
          "deviantart.com/{site_artist_identifier}",
          "{site_artist_identifier}.deviantart.com",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9\-]{1,20}/
      end

      def submission_template
        "https://www.deviantart.com/{site_artist_identifier}/art/{site_submission_identifier}"
      end
    end
  end
end
