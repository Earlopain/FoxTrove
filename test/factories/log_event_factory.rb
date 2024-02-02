# frozen_string_literal: true

FactoryBot.define do
  factory :log_event do
    action { :scraper_request }
    payload { {} }

    for_artist

    trait :for_artist do
      association :loggable, factory: :artist
    end
  end
end
