# frozen_string_literal: true

FactoryBot.define do
  factory :log_event do
    action { :scraper_request }
    payload { {} }

    transient do
      loggable { nil }
    end

    before(:create) do |log_event, evaluator|
      log_event.loggable_id = evaluator.loggable.id
      log_event.loggable_type = evaluator.loggable.class.name
    end
  end
end
