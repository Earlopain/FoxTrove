# frozen_string_literal: true

class LogEvent < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  enum action: {
    scraper_request: 0,
  }
end
