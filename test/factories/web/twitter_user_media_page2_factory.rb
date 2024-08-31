FactoryBot.define do
  factory :twitter_user_media_page2, parent: :twitter_timeline do
    instructions do
      [
        {
          type: "TimelineAddToModule",
          moduleEntryId: "profile-grid-0",
          moduleItems: tweets.map do |tweet|
            {
              entryId: "profile-grid-0-tweet-#{tweet[:rest_id]}",
              item: tweet,
            }
          end,
        },
        {
          type: "TimelineAddEntries",
          entries: [
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
