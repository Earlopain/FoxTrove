# frozen_string_literal: true

class LogEvent < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  enum action: {
    scraper_request: 0,
  }

  PARAMETER_FILTER = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

  def self.add!(model, action, payload = {})
    create!(
      loggable_id: model.id,
      loggable_type: model.class.name,
      action: action,
      payload: PARAMETER_FILTER.filter(payload),
    )
  end

  def self.search(params)
    q = all

    q = q.attribute_matches(params[:loggable_id], :loggable_id)
    q = q.attribute_matches(params[:loggable_type], :loggable_type)
    q = q.attribute_matches(params[:action], :action)

    q.order(id: :desc)
  end
end
