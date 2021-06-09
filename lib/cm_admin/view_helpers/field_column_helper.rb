module CmAdmin
  module ViewHelpers
    module ColumnFieldHelper

      def column_for_field_helper(ar_object, column)
        value = ar_object.send(column.db_column_name)
        case column.column_type
        when :datetime
          if column.format.present?
            value = ar_object.send(column.db_column_name).strftime(column.format)
          else
            value = ar_object.send(column.db_column_name).strftime("%d/%m/%Y")
          end
          if column.prefix.present?
            value = column.prefix.to_s + ' ' + value
          end
        end
        return value
      end

    end
  end
end
