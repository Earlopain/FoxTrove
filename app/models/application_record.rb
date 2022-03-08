class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :moderation_logs, as: :loggable

  def self.belongs_to_creator
    class_eval do
      belongs_to :creator, class_name: "User"
    end
  end

  concerning :SearchMethods do
    class_methods do
      def attributes_matching(attributes, params)
        params = params.with_indifferent_access if params.respond_to? :with_indifferent_access
        q = distinct.joins(join_hash(attributes, params))

        paths = hash_paths(attributes)
        paths.each do |path|
          path_parts = path.split(".")
          if path_parts.length == 1
            table_string = table_name
            column_string = path_parts[0]
          else
            table_string, column_string = path_parts.last(2)
          end
          value = params.dig(*path_parts)
          q = q.attribute_matches(table_string.classify.constantize, column_string, value)
        end
        q
      end

      def attribute_matches(model_class, attribute, value)
        return all if value.nil?

        column = model_class.column_for_attribute(attribute)
        qualified_column = "#{model_class.table_name}.#{column.name}"
        case column.sql_type_metadata.type
        when :text
          value = value.gsub("_", "\\_").gsub("%", "\\%").gsub("*", "%").gsub("\\", "\\\\\\\\")
          where("#{qualified_column} ILIKE ?", value)
        when :integer
          if value.is_a?(Array)
            where("#{qualified_column} IN(?)", value.first(100))
          else
            where("#{qualified_column} IN(?)", value.to_s.split(",").first(100))
          end
        else
          raise ArgumentError, "unhandled attribute type: #{column.sql_type_metadata.type}"
        end
      end

      def hash_paths(input)
        result = []
        if input.is_a? Array
          result = input.select { |value| value.is_a? Symbol }.map(&:to_s)
          input = input.find { |value| value.is_a? Hash }
        end
        return result if input.nil?

        result.concat(input.flat_map do |key, value|
          case value
          when Hash, Array
            hash_paths(value).map { |str| "#{key}.#{str}" }
          when Symbol
            "#{key}.#{value}"
          else
            key
          end
        end)
      end

      def join_hash(input, params, previous_keys = [])
        input = input.find { |value| value.is_a? Hash } if input.is_a? Array
        return {} if input.nil? || input.is_a?(Symbol)

        input = input.reject do |key, _value|
          params.dig(*previous_keys, key).nil?
        end

        input.map do |key, value|
          [key, join_hash(value, params, previous_keys + [key])]
        end.to_h
      end
    end
  end
end
