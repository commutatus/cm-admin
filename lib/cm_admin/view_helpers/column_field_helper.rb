module CmAdmin
  module ViewHelpers
    module ColumnFieldHelper

      def column_for_field_helper(ar_object, column)
        value = ar_object.send(column.db_column_name)
        formatted_value = CmAdmin::Models::Column.format_data_type(column, value)
        if column.prefix.present?
          formatted_value = column.prefix.to_s + ' ' + formatted_value
        end
        if column.suffix.present?
          formatted_value = formatted_value + ' ' + column.suffix.to_s
        end
        return formatted_value
      end

    end
  end
end
