# frozen_string_literal: true

FactoryBot.define do
  factory :json, class: OpenStruct do # rubocop:disable Style/OpenStructUse
    skip_create
  end
end

class JsonStrategy < FactoryBot::Strategy::Create
  def result(evaluation)
    super.to_json
  end

  def to_sym
    :json
  end
end

FactoryBot.register_strategy(:json, JsonStrategy)
