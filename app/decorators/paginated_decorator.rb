# frozen_string_literal: true

class PaginatedDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?, to: :@object
  delegate *Array.instance_methods(false), to: :collection # rubocop:disable Lint/AmbiguousOperator

  def initialize(object)
    @object = object
  end

  def collection
    @collection ||= @object.map(&:decorate)
  end
end
