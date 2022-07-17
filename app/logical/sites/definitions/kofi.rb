# frozen_string_literal: true

module Sites
  module Definitions
    class Kofi < SimpleDefinition
      def enum_value
        "kofi"
      end

      def display_name
        "Ko-fi"
      end

      def homepage
        "https://ko-fi.com/"
      end

      def gallery_templates
        "ko-fi.com/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{3,40}/
      end
    end
  end
end
