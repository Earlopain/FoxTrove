module Sites
  module Definitions
    module YoutubeLegacy
      module_function

      def enum_value
        "youtube_legacy"
      end

      def display_name
        "Youtube"
      end

      def homepage
        "https://youtube.com/"
      end

      def gallery_templates
        "youtube.com/user/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9]{3,30}/
      end
    end
  end
end