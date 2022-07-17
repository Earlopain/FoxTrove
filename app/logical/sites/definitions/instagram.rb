# frozen_string_literal: true

module Sites
  module Definitions
    module Instagram
      module_function

      def enum_value
        "instagram"
      end

      def display_name
        "Instagram"
      end

      def homepage
        "https://www.instagram.com"
      end

      def gallery_templates
        "instagram.com/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_.]{1,30}/
      end

      def submission_template
        "https://www.instagram.com/p/{site_submission_identifier}"
      end
    end
  end
end
