# frozen_string_literal: true

module Sites
  module Definitions
    module Reddit
      module_function

      def enum_value
        "reddit"
      end

      def display_name
        "Reddit"
      end

      def homepage
        "https://www.reddit.com"
      end

      def gallery_templates
        [
          "{reddit_old_new}reddit.com/user/{site_artist_identifier}",
          "{reddit_old_new}reddit.com/u/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{3,20}/
      end

      def submission_template
        "https://redd.it/{site_submission_identifier}"
      end
    end
  end
end
