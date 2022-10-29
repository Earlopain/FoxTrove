# frozen_string_literal: true

module Sites
  module Definitions
    class Afterdark < SimpleDefinition
      def enum_value
        "afterdark"
      end

      def display_name
        "AfterDark"
      end

      def homepage
        "https://afterdark.art/"
      end

      def gallery_templates
        "afterdark.art/user/{site_artist_identifier}"
      end

      def username_identifier_regex
        %r/[^\/]{1,100}/
      end

      def submission_template
        "https://afterdark.art/image/{site_submission_identifier}"
      end
    end
  end
end
