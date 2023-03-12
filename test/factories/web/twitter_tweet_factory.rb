# frozen_string_literal: true

FactoryBot.define do
  factory :twitter_tweet, parent: :json do
    description { "" }
    is_promoted { false }

    json do
      {
        content: {
          entryType: "TimelineTimelineItem",
          itemContent: {
            tweet_results: {
              result: {
                legacy: {
                  id_str: "123",
                  created_at: "Fri Nov 30 01:19:50 +0000 2018",
                  display_text_range: [0, description.length],
                  entities: {
                    urls: [],
                  },
                  extended_entities: {
                    media: {},
                  },
                  full_text: description,
                },
              },
            },
            ** (is_promoted ? { promotedMetadata: {} } : {}),
          },
        },
      }
    end
  end
end
