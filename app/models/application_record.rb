class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :log_events, as: :loggable, dependent: nil

  def add_log_event(action, **payload)
    LogEvent.create!(
      loggable_id: id,
      loggable_type: self.class.name,
      action: action,
      payload: payload,
    )
  end

  concerning :SearchMethods do
    class_methods do
      def attribute_matches(value, attribute)
        return all if value.nil?

        column, model_class = get_column_and_model_class(attribute)
        q = distinct.joins(join_hash(attribute))
        q.column_matches(model_class, column, value)
      end

      def column_matches(model_class, column_name, value)
        column = model_class.column_for_attribute(column_name)
        qualified_column = "#{model_class.table_name}.#{column.name}"
        values = (value.is_a?(Array) ? value : value.to_s.split(",")).first(100)
        case column.sql_type_metadata.type
        when :text
          if values.count == 1
            value = values.first.gsub("_", "\\_").gsub("%", "\\%").gsub("*", "%").gsub("\\", "\\\\\\\\")
            where("#{qualified_column} ILIKE ?", value)
          else
            where("LOWER(#{qualified_column}) IN(?)", values.map(&:downcase))
          end
        when :integer
          where("#{qualified_column} IN(?)", values)
        else
          raise ArgumentError, "unhandled attribute type: #{column.sql_type_metadata.type}"
        end
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
