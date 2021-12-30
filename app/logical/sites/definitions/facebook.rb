module Sites
  module Definitions
    module Facebook
      module_function

      def enum_value
        "facebook"
      end

      def display_name
        "Facebook"
      end

      def homepage
        "https://www.facebook.com/"
      end

      def gallery_templates
        "facebook.com/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9.\-]{1,35}/
      end
    end
  end
end
