# frozen_string_literal: true

module Sites
  module Definitions
    class Furaffinity < ScraperDefinition
      def enum_value
        "furaffinity"
      end

      def display_name
        "FurAffinity"
      end

      def homepage
        "https://www.furaffinity.net"
      end

      def gallery_templates
        [
          "{furaffinity_sfw}furaffinity.net/user/{site_artist_identifier}",
          "{furaffinity_sfw}furaffinity.net/gallery/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-~.]{1,30}/
      end

      def submission_template
        "https://www.furaffinity.net/view/{site_submission_identifier}"
      end
    end
  end
end
