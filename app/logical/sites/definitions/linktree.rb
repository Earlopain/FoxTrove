# frozen_string_literal: true

module Sites
  module Definitions
    class Linktree < SimpleDefinition
      def enum_value
        "linktree"
      end

      def display_name
        "linktree"
      end

      def homepage
        "https://linktr.ee/"
      end

      def gallery_templates
        "linktr.ee/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_.]{3,30}/
      end
    end
  end
end
