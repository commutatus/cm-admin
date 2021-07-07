module CmAdmin
  module ViewHelpers
    module FilterHelper

      def add_date_filter(filter)
        concat(content_tag(:div, class: 'filter-chips-wrapper hidden') do
          concat(content_tag(:div, class: 'filter-chip') do
            concat tag.input class: 'normal-input', placeholder: "#{filter.placeholder}", data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}
          end)
        end)
        return
      end
    end
  end
end
