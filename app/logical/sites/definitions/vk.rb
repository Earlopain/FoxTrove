module Sites
  module Definitions
    module Vk
      module_function

      def enum_value
        "vkontakte"
      end

      def display_name
        "VK"
      end

      def homepage
        "https://vk.com"
      end

      def gallery_templates
        "vk.com/{site_artist_identifier}"
      end

      def username_identifier_regex
        /[a-zA-Z0-9_.]{1,26}/
      end

      def submission_template
        "https://vk.com/{site_artist_identifier}?z=photo-{site_submission_identifier}/"
      end
    end
  end
end
