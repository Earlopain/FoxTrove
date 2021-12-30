module Sites
  module Definitions
    module Picarto
      module_function

      def enum_value
        "picarto"
      end

      def display_name
        "Picarto"
      end

      def homepage
        "https://picarto.tv/"
      end

      def gallery_templates
        "picarto.tv/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9]{3,24}/
      end
    end
  end
end
