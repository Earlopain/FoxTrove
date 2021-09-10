class ModerationLog < ApplicationRecord
  belongs_to_creator
  belongs_to :loggable, polymorphic: true
end
