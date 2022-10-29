# frozen_string_literal: true

module Sites
  module Definitions
    class Buzzly < SimpleDefinition
      def enum_value
        "buzzly"
      end

      def display_name
        "Buzzly"
      end

      def homepage
        "https://buzzly.art/"
      end

      def gallery_templates
        "buzzly.art/~{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_@\-\.]{1,20}/
      end

      def submission_template
        "https://buzzly.art/~{site_artist_identifier}/art/{site_submission_identifier}"
      end
    end
  end
end
