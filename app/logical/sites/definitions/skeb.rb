module Sites
  module Definitions
    module Skeb
      module_function

      def enum_value
        "skeb"
      end

      def display_name
        "Skeb"
      end

      def homepage
        "https://skeb.jp/"
      end

      def gallery_templates
        "skeb.jp/@{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_]{1,15}/
      end
    end
  end
end
