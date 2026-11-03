FactoryBot.define do
  factory :artist_url do
    association :artist

    sequence(:url_identifier) { |n| "artist_url_#{n}" }
    site_type { :twitter }
  end
end
