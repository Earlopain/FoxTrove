# frozen_string_literal: true

module Sites
  module Definitions
    module Sofurry
      module_function

      def enum_value
        "sofurry"
      end

      def display_name
        "Sofurry"
      end

      def homepage
        "https://www.sofurry.com"
      end

      def gallery_templates
        "{site_artist_identifier}.sofurry.com"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\\-]{1,25}/
      end

      def submission_template
        "https://www.sofurry.com/view/{site_submission_identifier}"
      end
    end
  end
end
