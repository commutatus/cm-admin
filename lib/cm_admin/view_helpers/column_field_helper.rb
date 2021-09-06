module CmAdmin
  module ViewHelpers
    module ColumnFieldHelper

      #adds prefix and suffix to a value
      def add_prefix_and_suffix_helper(value, prefix, suffix)
        "#{prefix} #{value} #{suffix}"
      end

      #formats the column value a field
      def column_for_field_helper(ar_object, column)
        value = ar_object.send(column.db_column_name)
        formatted_value = CmAdmin::Models::Column.format_data_type(column, value)
        formatted_value = add_prefix_and_suffix_helper(formatted_value, column.prefix, column.suffix)
        formatted_value = link_url_value_helper(column, value, formatted_value)
        return formatted_value
      end

      #column's value is either linked with 'url' attribute's value or its own value
      def link_url_value_helper(column, value, formatted_value)
        return formatted_value unless column.column_type.to_s == 'link'
        link_url_value = column.url.present? ? column.url : value
        final_value = "<a href=#{link_url_value}>#{formatted_value}</a>".html_safe
        return final_value
      end

    end
  end
end
