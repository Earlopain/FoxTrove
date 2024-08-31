FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "artist#{n}" }
  end
end
