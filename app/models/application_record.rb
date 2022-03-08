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
        q = all
        attributes.each do |attribute|
          value = params[attribute]
          next if value.nil?

          column = column_for_attribute(attribute)
          qualified_column = "#{table_name}.#{column.name}"
          case column.sql_type_metadata.type
          when :text
            value = value.gsub("_", "\\_").gsub("*", "%").gsub("%", "\\%").gsub("\\", "\\\\\\\\")
            q = q.where("#{qualified_column} ILIKE ?", value)
          else
            raise ArgumentError, "unhandled attribute type"
          end
        end
        q
      end
    end
  end
end
