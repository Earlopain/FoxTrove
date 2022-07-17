# frozen_string_literal: true

class LogEvent < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
