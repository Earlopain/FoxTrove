module Sites
  module Definitions
    module Tumblr
      module_function

      def enum_value
        "tumblr"
      end

      def display_name
        "Tumblr"
      end

      def homepage
        "https://www.tumblr.com"
      end

      def gallery_templates
        "{site_artist_identifier}.tumblr.com"
      end

      def username_identifier_regex
        /[a-zA-Z0-9\-]{1,32}/
      end

      def submission_template
        "https://{site_artist_identifier}.tumblr.com/post/{site_submission_identifier}/"
      end
    end
  end
end
