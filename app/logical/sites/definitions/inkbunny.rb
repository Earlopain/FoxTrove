module Sites
  module Definitions
    module Inkbunny
      module_function

      def enum_value
        "inkbunny"
      end

      def display_name
        "Inkbunny"
      end

      def homepage
        "https://inkbunny.net"
      end

      def gallery_templates
        "inkbunny.net/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9]{1,22}/
      end

      def submission_template
        "https://inkbunny.net/s/{site_submission_identifier}"
      end
    end
  end
end
