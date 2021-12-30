module Sites
  module Definitions
    module Baraag
      module_function

      def enum_value
        "baraag"
      end

      def display_name
        "Baraag"
      end

      def homepage
        "https://baraag.net/"
      end

      def gallery_templates
        "baraag.net/@{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{1,30}/
      end
    end
  end
end
