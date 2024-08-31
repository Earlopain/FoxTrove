FactoryBot.define do
  factory :twitter_url_entity, parent: :json do
    short_url { nil }
    long_url { nil }
    start { nil }
    stop { nil }

    json do
      {
        expanded_url: long_url,
        url: short_url,
        indices: [start, stop],
      }
    end
  end
end
