module CmAdmin
  module ViewHelpers
    module FilterHelper

      def generate_filters(filters)
        search_filter = filters.select{ |x| x.filter_type.eql?(:search) }.last
        other_filters = filters.reject{ |x| x.filter_type.eql?(:search) }
        concat(content_tag(:div, class: 'cm-filters-v2') do
          concat(content_tag(:div, class: 'cm-filters-v2__inner') do
            concat add_search_filter(search_filter) if search_filter
            if other_filters
              concat filter_ui(other_filters)
              concat add_filters_dropdown(other_filters)
            end
          end)
        end)
        return
      end

      def add_filters_dropdown(filters)
        concat(content_tag(:div, class: 'dropdown add-filter-btn', data: {bs_toggle: "dropdown"}) do
          tag.span '+ Add filter'
        end)
        concat(content_tag(:ul, class: 'dropdown-menu', id:'add-filter-dropdown') do
          concat tag.input id: 'cm-add-filter-search', placeholder: 'Search for filter'
          filters.each do |filter|
            concat(content_tag(:li, class: 'pointer dropdown-item', data: {behavior: 'filter-option', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}) do
              tag.span filter.db_column_name.to_s.titleize
            end)
          end
        end)
        return
      end

      def filter_ui(filters)
        filters.each do |filter|
          case filter.filter_type
          when :date
            concat add_date_filter(filter)
          when :range
            concat add_range_filter(filter)
          end
        end
        return
      end

      def add_search_filter(filter)
        tag.div class: 'filter-search' do
          tag.div class: 'form-field' do
            tag.div class: 'field-input-wrapper' do
              concat(content_tag(:input, class: 'search-input', value: "#{params.dig(:filters, :search)}", placeholder: "#{filter.placeholder}") do
                tag.span class: 'search-input-icon' do
                  tag.i class: 'fa fa-search'
                end
              end)
            end
          end
        end
      end

      def add_range_filter(filter)
        concat(content_tag(:div, class: 'filter-chips-wrapper hidden') do
          concat(content_tag(:div, class: 'filter-chip d-flex') do
            concat tag.input type: 'number', min: '0', step: '1', class: 'normal-input', placeholder: 'From', data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}
            concat tag.input type: 'number', min: '0', step: '1', class: 'normal-input ml-2', placeholder: 'To', data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}
          end)
        end)
        return
      end

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
