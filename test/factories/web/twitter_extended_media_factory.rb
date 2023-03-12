# frozen_string_literal: true

FactoryBot.define do
  factory :twitter_extended_media, parent: :json do
    type { nil }
    media_url { "" }
    short_url { "abc" }

    json do
      {
        type: type,
        media_url_https: media_url,
        display_url: "pic.twitter.com/#{short_url}",
        url: "https://t.co/#{short_url}",
      }
    end

    factory :twitter_photo_media do
      type { "photo" }
    end
  end
end
