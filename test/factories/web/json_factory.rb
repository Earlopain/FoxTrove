FactoryBot.define do
  factory :json, class: Hash do
    skip_create

    initialize_with { attributes[:json] }
  end
end
