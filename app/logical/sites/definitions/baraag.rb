# frozen_string_literal: true

module Sites
  module Definitions
    class Baraag < ScraperDefinition
      def enum_value
        "baraag"
      end

      def display_name
        "Baraag"
      end

      def homepage
        "https://baraag.net/"
      end

      def gallery_templates
        "baraag.net/@{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{1,30}/
      end

      def submission_template
        "https://baraag.net/@{site_artist_identifier}/{site_submission_identifier}"
      end
    end
  end
end
