FactoryBot.define do
  factory :twitter_user_media_page1, parent: :twitter_timeline do
    instructions do
      [
        {
          type: "TimelineAddEntries",
          entries: [
            {
              entryId: "profile-grid-0",
              content: {
                entryType: "TimelineTimelineModule",
                items: tweets.map do |tweet|
                  {
                    entryId: "profile-grid-0-tweet-#{tweet[:rest_id]}",
                    item: tweet,
                  }
                end,
              },
            },
            {
              content: {
                entryType: "TimelineTimelineCursor",
                value: "DummyNextCursor",
                cursorType: "Bottom",
              },
            },
          ],
        },
      ]
    end
  end
end
