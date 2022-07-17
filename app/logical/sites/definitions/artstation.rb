# frozen_string_literal: true

module Sites
  module Definitions
    class Artstation < ScraperDefinition
      def enum_value
        "artstation"
      end

      def display_name
        "ArtStation"
      end

      def homepage
        "https://www.artstation.com"
      end

      def gallery_templates
        [
          "artstation.com/artist/{site_artist_identifier}",
          "artstation.com/{site_artist_identifier}",
          "{site_artist_identifier}.artstation.com/",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,63}/
      end

      def submission_template
        "https://www.artstation.com/artwork/{site_submission_identifier}"
      end
    end
  end
end
