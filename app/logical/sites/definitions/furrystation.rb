# frozen_string_literal: true

module Sites
  module Definitions
    class Furrystation < SimpleDefinition
      def enum_value
        "furrystation"
      end

      def display_name
        "FurryStation"
      end

      def homepage
        "https://furrystation.com/"
      end

      def gallery_templates
        "furrystation.com/{site_artist_identifier}/"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,50}/
      end

      def submission_template
        "https://furrystation.com/s/{site_submission_identifier}/"
      end
    end
  end
end
