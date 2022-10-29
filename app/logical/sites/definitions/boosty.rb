# frozen_string_literal: true

module Sites
  module Definitions
    class Boosty < SimpleDefinition
      def enum_value
        "boosty"
      end

      def display_name
        "Boosty"
      end

      def homepage
        "https://boosty.to/"
      end

      def gallery_templates
        "boosty.to/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_.\-]{3,50}/
      end

      def submission_template
        "https://boosty.to/{site_artist_identifier}/posts/{site_submission_identifier}"
      end
    end
  end
end
