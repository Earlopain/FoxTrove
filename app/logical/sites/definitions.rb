module Sites
  module Definitions
    def self.from_enum(value)
      ALL.detect { |definition| definition.enum_value == value }
    end

    def self.from_url(url)
      begin
        uri = Addressable::URI.parse url
      rescue Addressable::URI::InvalidURIError
        return nil
      end

      ALL.filter_map do |definition|
        definition.match_for uri
      end.first
    end

    class IdentifierProcessor
      def self.match(name)
        return /^(https?:\/\/)?(www\.)?/ if name == "prefix"
        return /((old|new)\.)?/ if name == "reddit_old_new"
        return /[a-zA-Z]{2}\/|^$/ if name == "pixiv_lang"
        return /[^\/?&#]*/ if name == "site_artist_identifier"
        return /.*?/ if name == "remaining"

        raise StandardError, "Unhandled matcher #{name}"
      end
    end

    TWITTER = Definition.new(
      enum_value: "twitter",
      display_name: "Twitter",
      homepage: "https://twitter.com",
      gallery_templates: ["twitter.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,15}/,
      submission_template: "https://twitter.com/{site_artist_identifier}/status/{site_submission_identifier}/"
    )

    FURAFFINITY = Definition.new(
      enum_value: "furaffinity",
      display_name: "FurAffinity",
      homepage: "https://www.furaffinity.net",
      gallery_templates: ["furaffinity.net/user/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_\-~.]{1,30}/,
      submission_template: "https://www.furaffinity.net/view/{site_submission_identifier}/"
    )

    INKBUNNY = Definition.new(
      enum_value: "inkbunny",
      display_name: "Inkbunny",
      homepage: "https://inkbunny.net",
      gallery_templates: ["inkbunny.net/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9]{1,22}/,
      submission_template: "https://inkbunny.net/s/{site_submission_identifier}/"
    )

    SOFURRY = Definition.new(
      enum_value: "sofurry",
      display_name: "Sofurry",
      homepage: "https://www.sofurry.com",
      gallery_templates: ["{site_artist_identifier}.sofurry.com"],
      username_identifier_regex: /[a-zA-Z0-9_\\-]{1,25}/,
      submission_template: "https://www.sofurry.com/view/{site_submission_identifier}/"
    )

    DEVIANTART = Definition.new(
      enum_value: "deviantart",
      display_name: "DeviantArt",
      homepage: "https://www.deviantart.com",
      gallery_templates: [
        "deviantart.com/{site_artist_identifier}",
        "{site_artist_identifier}.deviantart.com",
      ],
      username_identifier_regex: /[a-zA-Z0-9\-]{1,20}/,
      submission_template: "https://www.deviantart.com/{site_artist_identifier}/art/{site_submission_identifier}/"
    )

    ARTSTATION = Definition.new(
      enum_value: "artstation",
      display_name: "ArtStation",
      homepage: "https://www.artstation.com",
      gallery_templates: ["artstation.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,63}/,
      submission_template: "https://www.artstation.com/artwork/{site_submission_identifier}/"
    )

    PATREON = Definition.new(
      enum_value: "patreon",
      display_name: "Patreon",
      homepage: "https://www.patreon.com",
      gallery_templates: ["patreon.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,64}/,
      submission_template: "https://www.patreon.com/posts/{site_submission_identifier}/"
    )

    PIXIV = Definition.new(
      enum_value: "pixiv",
      display_name: "Pixiv",
      homepage: "https://www.pixiv.net",
      gallery_templates: [
        "pixiv.net/{pixiv_lang}users/{site_artist_identifier}",
        "pixiv.net/member.php?id={site_artist_identifier}/",
      ],
      username_identifier_regex: /[0-9]{1,8}/,
      submission_template: "https://www.pixiv.net/artworks/{site_submission_identifier}/"
    )

    WEASYL = Definition.new(
      enum_value: "weasyl",
      display_name: "Weasyl",
      homepage: "https://www.weasyl.com",
      gallery_templates: [
        "weasyl.com/~{site_artist_identifier}",
        "weasyl.com/profile/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9]{1,25}/,
      submission_template: "https://www.weasyl.com/~{site_artist_identifier}/submissions/{site_submission_identifier}/"
    )

    TUMBLR = Definition.new(
      enum_value: "tumblr",
      display_name: "Tumblr",
      homepage: "https://www.tumblr.com",
      gallery_templates: ["{site_artist_identifier}.tumblr.com"],
      username_identifier_regex: /[a-zA-Z0-9\-]{1,32}/,
      submission_template: "https://{site_artist_identifier}.tumblr.com/post/{site_submission_identifier}/"
    )

    REDDIT = Definition.new(
      enum_value: "reddit",
      display_name: "Reddit",
      homepage: "https://www.reddit.com",
      gallery_templates: [
        "{reddit_old_new}reddit.com/user/{site_artist_identifier}",
        "{reddit_old_new}reddit.com/u/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,20}/,
      submission_template: "https://redd.it/{site_submission_identifier}/"
    )

    NEWGROUNDS = Definition.new(
      enum_value: "newgrounds",
      display_name: "Newgrounds",
      homepage: "https://www.newgrounds.com",
      gallery_templates: ["{site_artist_identifier}.newgrounds.com"],
      username_identifier_regex: /[a-zA-Z0-9~]{1,20}/,
      submission_template: "https://www.newgrounds.com/art/view/{site_artist_identifier}/{site_submission_identifier}/"
    )

    VKONTAKTE = Definition.new(
      enum_value: "vkontakte",
      display_name: "VK",
      homepage: "https://vk.com",
      gallery_templates: ["vk.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,26}/,
      submission_template: "https://vk.com/{site_artist_identifier}?z=photo-{site_submission_identifier}/"
    )

    INSTAGRAM = Definition.new(
      enum_value: "instagram",
      display_name: "Instagram",
      homepage: "https://www.instagram.com",
      gallery_templates: ["instagram.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_.]{1,30}/,
      submission_template: "https://www.instagram.com/p/{site_submission_identifier}/"
    )

    ALL = [
      TWITTER,
      FURAFFINITY,
      INKBUNNY,
      SOFURRY,
      DEVIANTART,
      ARTSTATION,
      PATREON,
      PIXIV,
      WEASYL,
      TUMBLR,
      REDDIT,
      NEWGROUNDS,
      VKONTAKTE,
      INSTAGRAM,
    ].freeze
  end
end
