module Sites
  module Definitions
    module Pawoo
      module_function

      def enum_value
        "pawoo"
      end

      def display_name
        "Pawoo"
      end

      def homepage
        "https://pawoo.net/"
      end

      def gallery_templates
        "pawoo.net/@{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{1,30}/
      end
    end
  end
end
