# frozen_string_literal: true

module Sites
  module Definitions
    class Piczel < ScraperDefinition
      def enum_value
        "piczel"
      end

      def display_name
        "Piczel"
      end

      def homepage
        "https://piczel.tv/"
      end

      def gallery_templates
        [
          "https://piczel.tv/gallery/{site_artist_identifier}",
          "https://piczel.tv/watch/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{1,24}/
      end

      def submission_template
        "https://piczel.tv/gallery/image/{site_submission_identifier}"
      end
    end
  end
end
