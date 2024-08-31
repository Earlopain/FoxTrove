FactoryBot.define do
  factory :e6_iqdb_response, parent: :json do
    post_ids { [] }

    json do
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
