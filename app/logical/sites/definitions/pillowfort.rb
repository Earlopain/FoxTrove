module Sites
  module Definitions
    module Pillowfort
      module_function

      def enum_value
        "pillowfort"
      end

      def display_name
        "Pillowfort"
      end

      def homepage
        "https://www.pillowfort.social/"
      end

      def gallery_templates
        "pillowfort.social/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{1,20}/
      end
    end
  end
end
