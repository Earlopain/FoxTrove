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

      ALL.lazy.filter_map do |definition|
        definition.match_for uri
      end.first
    end

    class IdentifierProcessor
      def self.match(name)
        return /^(https?:\/\/)?(www\.)?/ if name == "prefix"
        return /((old|new)\.)?/ if name == "reddit_old_new"
        return /(sfw\.)?/ if name == "furaffinity_sfw"
        return /[a-zA-Z]{2}\/|^$/ if name == "pixiv_lang"
        return /[^\/?&#]*/ if name == "site_artist_identifier"
        return /.*?/ if name == "remaining"

        raise StandardError, "Unhandled matcher #{name}"
      end
    end

    TWITTER = ScraperDefinition.new(
      enum_value: "twitter",
      display_name: "Twitter",
      homepage: "https://twitter.com",
      gallery_templates: [
        "twitter.com/@{site_artist_identifier}",
        "twitter.com/{site_artist_identifier}",
        "mobile.twitter.com/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_]{1,15}/,
      submission_template: "https://twitter.com/{site_artist_identifier}/status/{site_submission_identifier}/"
    )

    FURAFFINITY = ScraperDefinition.new(
      enum_value: "furaffinity",
      display_name: "FurAffinity",
      homepage: "https://www.furaffinity.net",
      gallery_templates: [
        "{furaffinity_sfw}furaffinity.net/user/{site_artist_identifier}",
        "{furaffinity_sfw}furaffinity.net/gallery/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-~.]{1,30}/,
      submission_template: "https://www.furaffinity.net/view/{site_submission_identifier}/"
    )

    INKBUNNY = ScraperDefinition.new(
      enum_value: "inkbunny",
      display_name: "Inkbunny",
      homepage: "https://inkbunny.net",
      gallery_templates: ["inkbunny.net/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9]{1,22}/,
      submission_template: "https://inkbunny.net/s/{site_submission_identifier}/"
    )

    SOFURRY = ScraperDefinition.new(
      enum_value: "sofurry",
      display_name: "Sofurry",
      homepage: "https://www.sofurry.com",
      gallery_templates: ["{site_artist_identifier}.sofurry.com"],
      username_identifier_regex: /[a-zA-Z0-9_\\-]{1,25}/,
      submission_template: "https://www.sofurry.com/view/{site_submission_identifier}/"
    )

    DEVIANTART = ScraperDefinition.new(
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

    ARTSTATION = ScraperDefinition.new(
      enum_value: "artstation",
      display_name: "ArtStation",
      homepage: "https://www.artstation.com",
      gallery_templates: [
        "artstation.com/{site_artist_identifier}",
        "{site_artist_identifier}.artstation.com/",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,63}/,
      submission_template: "https://www.artstation.com/artwork/{site_submission_identifier}/"
    )

    PATREON = ScraperDefinition.new(
      enum_value: "patreon",
      display_name: "Patreon",
      homepage: "https://www.patreon.com",
      gallery_templates: ["patreon.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,64}/,
      submission_template: "https://www.patreon.com/posts/{site_submission_identifier}/"
    )

    PIXIV = ScraperDefinition.new(
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

    WEASYL = ScraperDefinition.new(
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

    TUMBLR = ScraperDefinition.new(
      enum_value: "tumblr",
      display_name: "Tumblr",
      homepage: "https://www.tumblr.com",
      gallery_templates: ["{site_artist_identifier}.tumblr.com"],
      username_identifier_regex: /[a-zA-Z0-9\-]{1,32}/,
      submission_template: "https://{site_artist_identifier}.tumblr.com/post/{site_submission_identifier}/"
    )

    REDDIT = ScraperDefinition.new(
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

    NEWGROUNDS = ScraperDefinition.new(
      enum_value: "newgrounds",
      display_name: "Newgrounds",
      homepage: "https://www.newgrounds.com",
      gallery_templates: ["{site_artist_identifier}.newgrounds.com"],
      username_identifier_regex: /[a-zA-Z0-9~\-]{1,20}/,
      submission_template: "https://www.newgrounds.com/art/view/{site_artist_identifier}/{site_submission_identifier}/"
    )

    VKONTAKTE = ScraperDefinition.new(
      enum_value: "vkontakte",
      display_name: "VK",
      homepage: "https://vk.com",
      gallery_templates: ["vk.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_.]{1,26}/,
      submission_template: "https://vk.com/{site_artist_identifier}?z=photo-{site_submission_identifier}/"
    )

    INSTAGRAM = ScraperDefinition.new(
      enum_value: "instagram",
      display_name: "Instagram",
      homepage: "https://www.instagram.com",
      gallery_templates: ["instagram.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_.]{1,30}/,
      submission_template: "https://www.instagram.com/p/{site_submission_identifier}/"
    )

    SUBSCRIBESTAR = SimpleDefinition.new(
      enum_value: "subscribestar",
      display_name: "SubscribeStar",
      homepage: "https://www.subscribestar.com/",
      gallery_templates: [
        "subscribestar.com/{site_artist_identifier}",
        "subscribestar.adult/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,512}/
    )

    KOFI = SimpleDefinition.new(
      enum_value: "kofi",
      display_name: "Ko-fi",
      homepage: "https://ko-fi.com/",
      gallery_templates: ["ko-fi.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{3,40}/
    )

    DISCORD = SimpleDefinition.new(
      enum_value: "discord",
      display_name: "Discord",
      homepage: "https://discord.com/",
      gallery_templates: [
        "discord.com/invite/{site_artist_identifier}",
        "discord.gg/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,25}/
    )

    FANBOX = SimpleDefinition.new(
      enum_value: "fanbox",
      display_name: "Fanbox",
      homepage: "https://www.fanbox.cc/",
      gallery_templates: ["{site_artist_identifier}.fanbox.cc"],
      username_identifier_regex: /[a-z0-9\-]{3,16}/
    )

    LINKTREE = SimpleDefinition.new(
      enum_value: "linktree",
      display_name: "linktree",
      homepage: "https://linktr.ee/",
      gallery_templates: ["linktr.ee/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_.]{3,30}/
    )

    CARRD = SimpleDefinition.new(
      enum_value: "carrd",
      display_name: "Carrd",
      homepage: "https://carrd.co/",
      gallery_templates: ["{site_artist_identifier}.carrd.co"],
      username_identifier_regex: /[a-z0-9\-]{3,32}/
    )

    TELEGRAM = SimpleDefinition.new(
      enum_value: "telegram",
      display_name: "Telegram",
      homepage: "https://telegram.org/",
      gallery_templates: [
        "t.me/{site_artist_identifier}",
        "telegram.me/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_]{5,64}/
    )

    TWITCH = SimpleDefinition.new(
      enum_value: "twitch",
      display_name: "Twitch",
      homepage: "https://www.twitch.tv/",
      gallery_templates: ["twitch.tv/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{4,25}/
    )

    PICARTO = SimpleDefinition.new(
      enum_value: "picarto",
      display_name: "Picarto",
      homepage: "https://picarto.tv/",
      gallery_templates: ["picarto.tv/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9]{3,24}/
    )

    GUMROAD = SimpleDefinition.new(
      enum_value: "gumroad",
      display_name: "Gumroad",
      homepage: "https://gumroad.com/",
      gallery_templates: [
        "{site_artist_identifier}.gumroad.com",
        "gumroad.com/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,20}/
    )

    SKEB = SimpleDefinition.new(
      enum_value: "skeb",
      display_name: "Skeb",
      homepage: "https://skeb.jp/",
      gallery_templates: ["skeb.jp/@{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,15}/
    )

    PAWOO = SimpleDefinition.new(
      enum_value: "pawoo",
      display_name: "Pawoo",
      homepage: "https://pawoo.net/",
      gallery_templates: ["pawoo.net/@{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,30}/
    )

    BARAAG = SimpleDefinition.new(
      enum_value: "baraag",
      display_name: "Baraag",
      homepage: "https://baraag.net/",
      gallery_templates: ["baraag.net/@{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_]{1,30}/
    )

    YOUTUBE_CHANNEL = SimpleDefinition.new(
      enum_value: "youtube_channel",
      display_name: "Youtube",
      homepage: "https://youtube.com/",
      gallery_templates: ["youtube.com/channel/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_\-]{24}/
    )

    YOUTUBE_LEGACY = SimpleDefinition.new(
      enum_value: "youtube_legacy",
      display_name: "Youtube",
      homepage: "https://youtube.com/",
      gallery_templates: ["youtube.com/user/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9]{3,30}/
    )

    YOUTUBE_VANITY = SimpleDefinition.new(
      enum_value: "youtube_vanity",
      display_name: "Youtube",
      homepage: "https://youtube.com/",
      gallery_templates: [
        "youtube.com/c/{site_artist_identifier}",
        "youtube.com/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9]{1,30}/
    )

    FACEBOOK = SimpleDefinition.new(
      enum_value: "facebook",
      display_name: "Facebook",
      homepage: "https://www.facebook.com/",
      gallery_templates: ["facebook.com/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9.\-]{1,35}/
    )

    HENTAI_FOUNDRY = SimpleDefinition.new(
      enum_value: "hentai_foundry",
      display_name: "Hentai Foundry",
      homepage: "https://www.hentai-foundry.com/",
      gallery_templates: [
        "www.hentai-foundry.com/user/{site_artist_identifier}",
        "www.hentai-foundry.com/pictures/user/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9\-]{1,35}/
    )

    PILLOWFORT = SimpleDefinition.new(
      enum_value: "pillowfort",
      display_name: "Pillowfort",
      homepage: "https://www.pillowfort.social/",
      gallery_templates: ["pillowfort.social/{site_artist_identifier}"],
      username_identifier_regex: /[a-zA-Z0-9_\-]{1,20}/
    )

    COMMISHES = SimpleDefinition.new(
      enum_value: "commishes",
      display_name: "Commishes",
      homepage: "https://commishes.com/",
      gallery_templates: [
        "portfolio.commishes.com/user/{site_artist_identifier}",
        "ych.commishes.com/user/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,20}/
    )

    FURRYNETWORK = SimpleDefinition.new(
      enum_value: "furrynetwork",
      display_name: "FurryNetwork",
      homepage: "https://furrynetwork.com/",
      gallery_templates: [
        "furrynetwork.com/{site_artist_identifier}",
        "beta.furrynetwork.com/{site_artist_identifier}",
      ],
      username_identifier_regex: /[a-zA-Z0-9_\-]{3,15}/
    )

    SCRAPERS = [
      TWITTER,
    ].freeze

    SIMPLE = [
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
      SUBSCRIBESTAR,
      KOFI,
      DISCORD,
      FANBOX,
      LINKTREE,
      CARRD,
      TELEGRAM,
      TWITCH,
      PICARTO,
      GUMROAD,
      SKEB,
      PAWOO,
      BARAAG,
      YOUTUBE_CHANNEL,
      YOUTUBE_LEGACY,
      YOUTUBE_VANITY,
      FACEBOOK,
      HENTAI_FOUNDRY,
      PILLOWFORT,
      COMMISHES,
      FURRYNETWORK,
    ].freeze

    ALL = SCRAPERS + SIMPLE
  end
end
