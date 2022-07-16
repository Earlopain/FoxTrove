class ModerationLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
