# frozen_string_literal: true

FactoryBot.define do
  factory :e6_iqdb_response, parent: :json do
    post_ids { [] }

    initialize_with do
      post_ids.map do |iqdb_match_id|
        {
          score: 90,
          post: {
            posts: {
              id: iqdb_match_id,
            },
          },
        }
      end
    end
  end
end
