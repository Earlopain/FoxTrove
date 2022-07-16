class LogEvent < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
