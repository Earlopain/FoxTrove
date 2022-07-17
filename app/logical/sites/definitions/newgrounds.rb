# frozen_string_literal: true

module Sites
  module Definitions
    class Newgrounds < ScraperDefinition
      def enum_value
        "newgrounds"
      end

      def display_name
        "Newgrounds"
      end

      def homepage
        "https://www.newgrounds.com"
      end

      def gallery_templates
        "{site_artist_identifier}.newgrounds.com"
      end

      def username_identifier_regex
        /[a-zA-Z0-9~\-]{1,20}/
      end

      def submission_template
        "https://www.newgrounds.com/art/view/{site_artist_identifier}/{site_submission_identifier}"
      end
    end
  end
end
