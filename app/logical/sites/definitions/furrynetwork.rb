module Sites
  module Definitions
    module Furrynetwork
      module_function

      def enum_value
        "furrynetwork"
      end

      def display_name
        "FurryNetwork"
      end

      def homepage
        "https://furrynetwork.com/"
      end

      def gallery_templates
        [
          "furrynetwork.com/{site_artist_identifier}",
          "beta.furrynetwork.com/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,15}/
      end

      def submission_template
        "https://furrynetwork.com/artwork/{site_submission_identifier}"
      end
    end
  end
end
