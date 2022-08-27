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

        column_matches(self, attribute, value)
      end

      def join_attribute_matches(value, attribute)
        return all if value.nil?

        column, model_class = get_column_and_model_class(attribute)
        q = distinct.joins(join_hash(attribute))
        q.column_matches(model_class, column, value)
      end

      def column_matches(model_class, column_name, value)
        column = model_class.column_for_attribute(column_name)
        qualified_column = "#{model_class.table_name}.#{column.name}"
        values = value.is_a?(Array) ? value : value.to_s.split(",")
        return if values.empty?

        if model_class.defined_enums.key? column_name.to_s
          where("#{qualified_column} IN(?)", values.map { |v| model_class.defined_enums[column_name.to_s][v] })
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
          condition = where("#{qualified_column} ILIKE ?", text.gsub("_", "\\_").gsub("%", "\\%").gsub("*", "%").gsub("\\", "\\\\\\\\"))
          q = q.or(condition)
        end
        q
      end

      def get_column_and_model_class(attribute)
        path = hash_path(attribute)
        model_name  = path.second_to_last || table_name
        model_class = model_name.to_s.classify.constantize
        [path.last, model_class]
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
end
