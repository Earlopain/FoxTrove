# frozen_string_literal: true

module Sites
  module Definitions
    class YoutubeChannel < SimpleDefinition
      def enum_value
        "youtube_channel"
      end

      def display_name
        "Youtube"
      end

      def homepage
        "https://youtube.com/"
      end

      def gallery_templates
        "youtube.com/channel/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_\-]{24}/
      end
    end
  end
end
