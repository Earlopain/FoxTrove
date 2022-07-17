# frozen_string_literal: true

module Sites
  module Definitions
    class Carrd < SimpleDefinition
      def enum_value
        "carrd"
      end

      def display_name
        "Carrd"
      end

      def homepage
        "https://carrd.co/"
      end

      def gallery_templates
        "{site_artist_identifier}.carrd.co"
      end

      def username_identifier_regex
        /[a-z0-9\-]{3,32}/
      end
    end
  end
end
