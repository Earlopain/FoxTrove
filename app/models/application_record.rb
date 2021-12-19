class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :moderation_logs, as: :loggable

  def self.belongs_to_creator
    class_eval do
      belongs_to :creator, class_name: "User"
      before_validation(on: :create) do |rec|
        rec.creator_id = CurrentUser.id if rec.creator_id.nil?
      end
    end
  end
end
