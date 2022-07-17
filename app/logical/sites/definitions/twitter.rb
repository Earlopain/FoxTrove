# frozen_string_literal: true

module Sites
  module Definitions
    module Twitter
      module_function

      def enum_value
        "twitter"
      end

      def display_name
        "Twitter"
      end

      def homepage
        "https://twitter.com"
      end

      def gallery_templates
        [
          "twitter.com/@{site_artist_identifier}",
          "twitter.com/{site_artist_identifier}",
          "mobile.twitter.com/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{1,15}/
      end

      def submission_template
        "https://twitter.com/{site_artist_identifier}/status/{site_submission_identifier}"
      end
    end
  end
end
