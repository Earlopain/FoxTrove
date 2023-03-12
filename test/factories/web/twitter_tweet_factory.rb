# frozen_string_literal: true

FactoryBot.define do
  factory :twitter_tweet, parent: :json do
    description { "" }
    url_entities { [] }
    description_start { 0 }
    description_end { description.length }
    is_promoted { false }
    media { [] }

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
                  display_text_range: [description_start, description_end],
                  entities: {
                    urls: url_entities,
                  },
                  extended_entities: {
                    media: media,
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
