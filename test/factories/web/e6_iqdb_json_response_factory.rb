# frozen_string_literal: true

FactoryBot.define do
  factory :e6_iqdb_json_response, class: OpenStruct do
    skip_create
    transient do
      post_ids { [] }
    end

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
      end.to_json
    end
  end
end
