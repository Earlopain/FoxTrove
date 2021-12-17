class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :moderation_logs, as: :loggable

  def self.belongs_to_creator
    class_eval do
      belongs_to :creator, class_name: "User"
      before_validation(on: :create) do |rec|
        if rec.creator_id.nil?
          rec.creator_id = CurrentUser.id
        end
      end
    end
  end

  def self.update_or_create(attributes)
    raise StandardError, "Tried to update_or_create more than one records" if count > 1

    obj = first || new
    obj.assign_attributes attributes
    obj
  end
end
