module CmAdmin
  module ViewHelpers
    module FilterHelper

      def generate_filters(filters)
        search_filter = filters.select{ |x| x.filter_type.eql?(:search) }.last
        other_filters = filters.reject{ |x| x.filter_type.eql?(:search) }
        concat(content_tag(:div, class: 'cm-filters-v2') do
          concat(content_tag(:div, class: 'cm-filters-v2__inner') do
            concat add_search_filter(search_filter) if search_filter
            if other_filters.any?
              concat filter_ui(other_filters)
              concat add_filters_dropdown(other_filters)
            end
            concat clear_filters
          end)
        end)
        return
      end

      def add_filters_dropdown(filters)
        concat(content_tag(:div, class: 'dropdown add-filter-btn', data: {bs_toggle: 'dropdown'}) do
          tag.span '+ Add filter'
        end)

        concat(content_tag(:div, class: 'dropdown-menu dropdown-popup') do
          concat(content_tag(:div, class: 'popup-base') do
            concat(content_tag(:div, class: 'popup-inner') do
              concat(content_tag(:div, class: 'search-area') do
                concat tag.input id: 'cm-add-filter-search', placeholder: 'Search for filter'
              end)
              concat(content_tag(:div, class: 'list-area', id: 'add-filter-dropdown') do
                filters.each do |filter|
                  concat(content_tag(:div, class: 'pointer dropdown-item list-item', data: {behavior: 'filter-option', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}) do
                    tag.span filter.db_column_name.to_s.titleize
                  end)
                end
              end)
            end)
          end)
        end)
        return
      end

      def clear_filters
        concat(content_tag(:div, class: "clear-btn #{params.dig(:filters) ? '' : 'hidden'}") do
          tag.span 'Clear all'
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
          when :single_select, :multi_select
            concat add_select_filter(filter)
          end
        end
        return
      end

      def add_search_filter(filter)
        tag.div class: 'filter-search mr-3' do
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
        value = params.dig(:filters, :range, :"#{filter.db_column_name}")
        concat(content_tag(:div, class: "position-relative mr-3 #{value ? '' : 'hidden'}") do
          concat(content_tag(:div, class: 'filter-chip', data: {behaviour: 'filter-input', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}) do
            concat tag.span "#{filter.db_column_name.to_s.titleize} is "
            concat tag.span "#{value}"
          end)

          concat(content_tag(:div, class: 'position-absolute mt-2 range-container hidden') do
            concat tag.input type: 'number', min: '0', step: '1', class: 'range-item', value: "#{value ? value.split(' to ')[0] : ''}", placeholder: 'From', data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}
            concat tag.input type: 'number', min: '0', step: '1', class: 'range-item', value: "#{value ? value.split(' to ')[1] : ''}", placeholder: 'To', data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}
          end)
        end)
        return
      end

      def add_date_filter(filter)
        value = params.dig(:filters, :date, :"#{filter.db_column_name}")
        concat(content_tag(:div, class: "position-relative mr-3 #{value ? '' : 'hidden'}") do
          concat(content_tag(:div, class: 'filter-chip', value: "#{value ? value : ''}", data: {behaviour: 'filter-input', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}) do
            concat tag.span "#{filter.db_column_name.to_s.titleize} is "
            concat tag.span "#{value}"
          end)

          concat(content_tag(:div, class: 'date-filter-wrapper w-100') do
            concat tag.input class: 'w-100 pb-1', value: "#{value ? value : ''}", data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"}
          end)
        end)
        return
      end

        concat(content_tag(:div, class: "filter-chips-wrapper #{value ? '' : 'hidden'}") do
          concat(content_tag(:div, class: 'filter-chip') do
          end)
        end)
        return
      end

      def add_select_filter(filter)
        value = params.dig(:filters, :"#{filter.filter_type}", :"#{filter.db_column_name}")
        concat(content_tag(:div, class: "filter-chips-wrapper #{value ? '' : 'hidden'}") do
          concat(content_tag(:div, class: 'filter-chip') do
            concat content_tag(:select, options_for_select(filter.collection, selected: value), class: 'select-2', multiple: filter.filter_type.eql?(:multi_select), data: {behaviour: 'filter', filter_type: "#{filter.filter_type}", db_column: "#{filter.db_column_name}"})
          end)
        end)
        return
      end
    end
  end
end
