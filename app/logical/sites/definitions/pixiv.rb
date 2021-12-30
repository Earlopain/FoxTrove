module Sites
  module Definitions
    module Pixiv
      module_function

      def enum_value
        "pixiv"
      end

      def display_name
        "Pixiv"
      end

      def homepage
        "https://www.pixiv.net"
      end

      def gallery_templates
        [
          "pixiv.net/{pixiv_lang}users/{site_artist_identifier}",
          "pixiv.net/member.php?id={site_artist_identifier}/",
        ]
      end

      def username_identifier_regex
        /[0-9]{1,8}/
      end

      def submission_template
        "https://www.pixiv.net/artworks/{site_submission_identifier}/"
      end

      # TODO: Hook this up
      def image_domains
        "pximg.net"
      end

      def download_headers
        { "Referer" => "https://www.pixiv.net" }
      end
    end
  end
end
