class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.belongs_to_creator
    class_eval do
      belongs_to :creator, class_name: "Account"
    end
  end
end
