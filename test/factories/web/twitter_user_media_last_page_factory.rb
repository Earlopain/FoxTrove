FactoryBot.define do
  factory :twitter_user_media_last_page, parent: :twitter_timeline do
    instructions do
      [
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
