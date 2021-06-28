module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(f, field)
        case field.input_type
        when :integer
          return f.number_field field.field_name, class: 'normal-input', data: {behaviour: 'integer-only'}
        when :decimal
          return f.number_field field.field_name, class: 'normal-input', data: {behaviour: 'decimal-only'}
        when :string
          return f.text_field field.field_name, class: 'normal-input'
        when :single_select
          return f.select field.field_name, options_for_select(field.collection || []), {}, class: 'normal-input select-2'
        when :multi_select
          return f.select field.field_name, options_for_select(field.collection || []), {}, class: 'normal-input select-2', multiple: true
        when :date
          return f.text_field field.field_name, class: 'normal-input', data: {behaviour: 'date-only'}
        when :date_time
          return f.text_field field.field_name, class: 'normal-input', data: {behaviour: 'date-time'}
        when :text
          return f.text_area field.field_name, class: 'normal-input'
        when :single_file_upload
          return f.file_field field.field_name, class: 'normal-input'
        when :multi_file_upload
          return f.file_field field.field_name, multiple: true, class: 'normal-input'
        end
      end
    end
  end
end
