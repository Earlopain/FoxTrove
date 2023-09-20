# frozen_string_literal: true

class ApplicationDecorator
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  # Delegate columns and instance methods
  def self.inherited(decorator_class)
    super
    model_class = decorator_class.name.delete_suffix("Decorator").constantize
    decorator_class.class_eval do
      delegate *model_class.column_names, *model_class.instance_methods(false), to: :@object # rubocop:disable Lint/AmbiguousOperator
    end
  end

  delegate_missing_to :@object
  delegate :to_param, :to_partial_path, to: :@object

  attr_reader :helpers
  alias h helpers

  def initialize(object)
    @object = object
    @helpers = ApplicationController.helpers
  end
end
