module Sites
  module Definitions
    module YoutubeVanity
      module_function

      def enum_value
        "youtube_vanity"
      end

      def display_name
        "Youtube"
      end

      def homepage
        "https://youtube.com/"
      end

      def gallery_templates
        [
          "youtube.com/c/{site_artist_identifier}",
          "youtube.com/{site_artist_identifier}",
        ]
      end

      def username_identifier_regex
        /[a-zA-Z0-9]{1,30}/
      end
    end
  end
end
