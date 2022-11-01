# frozen_string_literal: true

module Sites
  module Definitions
    class Artconomy < ScraperDefinition
      def enum_value
        "artconomy"
      end

      def display_name
        "Artconomy"
      end

      def homepage
        "https://artconomy.com/"
      end

      def gallery_templates
        [
          "artconomy.com/profile/{site_artist_identifier}/gallery/art",
          "artconomy.com/profile/{site_artist_identifier}/gallery",
          "artconomy.com/profile/{site_artist_identifier}/about",
          "artconomy.com/profile/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_@.+\-]{1,40}/
      end

      def submission_template
        "https://artconomy.com/submissions/{site_submission_identifier}"
      end
    end
  end
end
