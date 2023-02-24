# frozen_string_literal: true

FactoryBot.define do
  factory :twitter_user_media, parent: :json do
    tweets { [] }

    json do
      {
        data: {
          user: {
            result: {
              timeline_v2: {
                timeline: {
                  instructions: [
                    {
                      type: "TimelineAddEntries",
                      entries: [
                        *tweets,
                        {
                          content: {
                            entryType: "TimelineTimelineCursor",
                            value: "DummyNextCursor",
                            cursorType: "Bottom",
                          },
                        },
                      ],
                    },
                  ],
                },
              },
            },
          },
        },
      }
    end
  end
end
