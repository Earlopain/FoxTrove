# frozen_string_literal: true

FactoryBot.define do
  factory :artist_submission do
    association :artist_url

    created_at_on_site { Time.current }
    description_on_site { "" }
    sequence(:identifier_on_site) { |n| "submission_#{n}" }
    title_on_site { "" }
  end
end
