# frozen_string_literal: true

FactoryBot.define do
  factory :artist_url do
    association :artist

    sequence(:url_identifier) { |n| "artist_url_#{n}" }
    created_at_on_site { Time.current }
    about_on_site { "" }
    site_type { :twitter }
  end
end
