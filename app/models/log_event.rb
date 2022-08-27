# frozen_string_literal: true

class LogEvent < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  enum action: {
    scraper_request: 0,
  }

  def self.search(params)
    q = all

    q = q.attribute_matches(params[:loggable_id], :loggable_id)
    q = q.attribute_matches(params[:loggable_type], :loggable_type)
    q = q.attribute_matches(params[:action], :action)

    q.order(id: :desc)
  end
end
