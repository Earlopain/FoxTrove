class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :moderation_logs, as: :loggable

  def self.belongs_to_creator
    class_eval do
      belongs_to :creator, class_name: "Account"
    end
  end
end
