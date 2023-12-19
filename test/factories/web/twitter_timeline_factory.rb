# frozen_string_literal: true

FactoryBot.define do
  factory :twitter_timeline, parent: :json do
    instructions { [] }

    json do
      {
        data: {
          user: {
            result: {
              timeline_v2: {
                timeline: {
                  instructions: instructions,
                },
              },
            },
          },
        },
      }
    end
  end
end
