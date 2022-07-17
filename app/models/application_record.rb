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
      def attributes_matching(attributes, params)
        # TODO: Raise on unhandled params
        params = params.to_h.with_indifferent_access
        resolved_attributes = resolve_shorthand(attributes)
        resolved_params = resolve_params(params)

        q = distinct.joins(join_hash(resolved_attributes, resolved_params))

        paths = hash_paths(resolved_attributes)
        paths.each do |path|
          path_parts = path.split(".")
          if path_parts.length == 1
            table_string = table_name
            column_string = path_parts[0]
          else
            table_string, column_string = path_parts.last(2)
          end
          value = resolved_params.dig(*path_parts)
          q = q.attribute_matches(table_string.classify.constantize, column_string, value)
        end
        q
      end

      def attribute_matches(model_class, attribute, value)
        return all if value.nil?

        column = model_class.column_for_attribute(attribute)
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

      # Input:  [:id, :artist_id, artist_url_id]
      # Output: [:id, { artist_submission: { artist_url: [:id, { artist: :id }] } }]
      def resolve_shorthand(input)
        shorthand_values = shorthand_attribute_access.with_indifferent_access
        symbols = []
        hash = {}
        input.each do |entry|
          if entry.is_a? Symbol
            if shorthand_values[entry]
              hash.deep_merge!(shorthand_values[entry]) do |_key, v1, v2|
                Array.wrap(v1) + Array.wrap(v2)
              end
            else
              symbols.push entry
            end
          else
            hash.deep_merge! entry
          end
        end
        symbols + [hash]
      end

      # Input:  { id: 10, artist_url_id: 20, artist_id: 30 }
      # Output: { id: 10, artist_submission: { artist_url: { id: 20, artist: { id: 30 } } } }
      def resolve_params(input)
        shorthand_values = shorthand_attribute_access.with_indifferent_access
        input.to_h.each_with_object({}) do |(key, value), hash|
          if shorthand_values[key]
            path_parts = hash_paths(shorthand_values[key]).first.split(".")
            hash_part = hash
            while path_parts.count > 1
              part = path_parts.shift
              hash_part[part] ||= {}
              hash_part = hash_part[part]
            end
            hash_part[path_parts.pop] = value
          else
            hash[key] = value
          end
        end
      end

      # Input:  [:id, { artist_submission: { artist_url: [:id, { artist: :id }] } }]
      # Output: ["id", "artist_submission.artist_url.id", "artist_submission.artist_url.artist.id"]
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

      # Joins the necessary tables for the select to work.
      # Ignores tables which don't have values in the where clause.
      # Input:  [:id, { artist_submission: { artist_url: [:id, { artist: :id }] } }]
      # Input:  { id: 10, artist_submission: { artist_url: { id: 20, artist: { id: 30 } } } }
      # Output: { artist_submission: { artist_url: { artist: {} } } }
      #
      # Input:  [:id, { artist_submission: { artist_url: [:id, { artist: :id }] } }]
      # Input:  { id: 10, artist_submission: { artist_url: { id: 20 } } }
      # Output: { artist_submission: { artist_url: {} } }
      #
      # Input:  [:id, { artist_submission: { artist_url: [:id, { artist: :id }] } }]
      # Input:  { id: 10 }
      # Output: { }
      def join_hash(input, params, previous_keys = [])
        input = input.find { |value| value.is_a? Hash } if input.is_a? Array
        return {} if input.nil? || input.is_a?(Symbol)

        input = input.reject do |key, _value|
          params.dig(*previous_keys, key).nil?
        end

        input.to_h do |key, value|
          [key, join_hash(value, params, previous_keys + [key])]
        end
      end

      def shorthand_attribute_access
        {}
      end
    end
  end
end
