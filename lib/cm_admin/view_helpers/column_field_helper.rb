module CmAdmin
  module ViewHelpers
    module ColumnFieldHelper

      def column_for_field_helper(ar_object, column)
        value = ar_object.send(column.db_column_name)
        case column.column_type
        when :datetime
          format_value = column.format.present? ? column.format.to_s : '%d/%m/%Y'
          value = ar_object.send(column.db_column_name).strftime(format_value)
        when :enum
          value = ar_object.send(column.db_column_name).titleize
        when :integer
        when :decimal
          round_to = column.round.present? ? column.round.to_i : 2
          value = ar_object.send(column.db_column_name).round(round_to)
        end
        if column.prefix.present?
          value = column.prefix.to_s + ' ' + value
        end
        if column.suffix.present?
          value = value + ' ' + column.suffix.to_s
        end
        return value
      end

    end
  end
end
