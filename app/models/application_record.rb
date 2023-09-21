# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :log_events, as: :loggable, dependent: nil

  def add_log_event(action, payload = {})
    LogEvent.add!(self, action, payload)
  end

  concerning :SearchMethods do
    class_methods do
      def attribute_matches(value, attribute)
        return all if value.nil?

        _, column = get_model_class_and_column(attribute)
        column_matches(self, column, value)
      end

      def join_attribute_matches(value, attribute)
        return all if value.nil?

        q = distinct.joins(join_hash(attribute))
        model_class, column = get_model_class_and_column(attribute)
        q.column_matches(model_class, column, value)
      end

      def attribute_nil_check(value, attribute)
        return all unless value.in? [true, false]

        nil_check(value, attribute)
      end

      def join_attribute_nil_check(value, attribute)
        return all unless value.in? [true, false]

        model_class, column = get_model_class_and_column(attribute)
        qualified_column = "#{model_class.table_name}.#{column.name}"
        q = distinct.joins(join_hash(attribute))
        q.nil_check(value, qualified_column)
      end

      def nil_check(value, attribute)
        if value == true
          where.not(attribute => nil)
        else
          where(attribute => nil)
        end
      end

      def column_matches(model_class, column, value)
        qualified_column = "#{model_class.table_name}.#{column.name}"
        values = value.is_a?(Array) ? value : value.to_s.split(",")
        return if values.empty?

        if model_class.defined_enums.key? column.name.to_s
          where("#{qualified_column} IN(?)", values.map { |v| model_class.defined_enums[column.name.to_s][v] })
        else
          case column.sql_type_metadata.type
          when :text
            text_column_matches(qualified_column, values)
          when :integer
            where("#{qualified_column} IN(?)", values)
          else
            raise ArgumentError, "unhandled attribute type: #{column.sql_type_metadata.type}"
          end
        end
      end

      def text_column_matches(qualified_column, values)
        wildcard_text, non_wildcard_text = values.partition { |e| e.include?("*") }
        q = where("LOWER(#{qualified_column}) IN(?)", non_wildcard_text.map(&:downcase))
        wildcard_text.each do |text|
          condition = where("#{qualified_column} ILIKE ?", text.gsub("_", "\\_").gsub("%", "\\%").tr("*", "%").gsub("\\", "\\\\\\\\"))
          q = q.or(condition)
        end
        q
      end

      def get_model_class_and_column(attribute)
        remaining_path = hash_path(attribute)
        current_model = self
        current_path = remaining_path.shift || table_name

        while remaining_path.any?
          path_class_name = current_model.reflect_on_association(current_path)&.class_name || current_path.to_s.classify
          current_model = path_class_name.constantize
          current_path = remaining_path.shift
        end
        [current_model, current_model.column_for_attribute(current_path)]
      end

      # Input:  :id
      # Output: [:id]
      # Input:  artist_submission: { artist_url: { artist: :id } }
      # Output: [:artist_submission, :artist_url, :artist, :id]
      def hash_path(input)
        return [input] if input.is_a? Symbol

        key = input.keys.first
        [key] + hash_path(input[key])
      end

      # Joins the necessary tables for the select to work.
      # Input:  :id
      # Output  {}
      # Input:  artist_submission: { artist_url: { artist: :id } }
      # Output: { artist_submission: { artist_url: { artist: {} } } }
      def join_hash(input)
        return {} if input.is_a?(Symbol)

        input.transform_values { |v| join_hash(v) }
      end
    end
  end

  concerning :ControllerMethods do
    def decorate
      self.class.decorator_class.new(self)
    end

    class_methods do
      def decorator_class
        "#{model_name}Decorator".constantize
      end

      def pagy(params)
        page = [params[:page].to_i, 1].max
        limit = params[:limit].to_i <= 0 ? nil : params[:limit]
        pagy = Pagy.new(page: page, items: limit, count: count)
        [pagy, offset(pagy.offset).limit(pagy.items)]
      end

      def pagy_and_decorate(params)
        pagy, elements = pagy(params)
        [pagy, elements.map(&:decorate)]
      end
    end
  end
end
