# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def self.inherited(child_class)
    super
    child_class.class_eval do
      def self.collection_decorator_class
        PaginatedDecorator
      end
    end
  end

  delegate_all
end
