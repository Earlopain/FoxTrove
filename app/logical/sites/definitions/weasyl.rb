module Sites
  module Definitions
    module Weasyl
      module_function

      def enum_value
        "weasyl"
      end

      def display_name
        "Weasyl"
      end

      def homepage
        "https://www.weasyl.com"
      end

      def gallery_templates
        [
          "weasyl.com/~{site_artist_identifier}",
          "weasyl.com/profile/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9]{1,25}/
      end

      def submission_template
        "https://www.weasyl.com/~{site_artist_identifier}/submissions/{site_submission_identifier}/"
      end
    end
  end
end
