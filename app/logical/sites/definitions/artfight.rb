# frozen_string_literal: true

module Sites
  module Definitions
    class Artfight < SimpleDefinition
      def enum_value
        "artfight"
      end

      def display_name
        "Art Fight"
      end

      def homepage
        "https://artfight.net/"
      end

      def gallery_templates
        [
          "artfight.net/~{site_artist_identifier}",
          "artfight.net/~{site_artist_identifier}/attacks",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{1,20}/
      end

      def submission_template
        "https://artfight.net/attack/{site_submission_identifier}"
      end
    end
  end
end
