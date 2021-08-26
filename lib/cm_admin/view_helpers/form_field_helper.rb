module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(f, field)
        case field.input_type
        when :integer
          return f.text_field field.field_name, class: 'normal-input', disabled: field.disabled, value: field.custom_value, data: {behaviour: 'integer-only'}
        when :decimal
          return f.number_field field.field_name, class: 'normal-input', disabled: field.disabled, value: field.custom_value, data: {behaviour: 'decimal-only'}
        when :string
          return f.text_field field.field_name, class: 'normal-input', disabled: field.disabled, value: field.custom_value
        when :single_select
          return f.select field.field_name, options_for_select(field.collection || []), {}, class: 'normal-input select-2', disabled: field.disabled
        when :multi_select
          return f.select field.field_name, options_for_select(field.collection || []), {}, class: 'normal-input select-2', disabled: field.disabled, multiple: true
        when :date
          return f.text_field field.field_name, class: 'normal-input', disabled: field.disabled, value: field.custom_value, data: {behaviour: 'date-only'}
        when :date_time
          return f.text_field field.field_name, class: 'normal-input', disabled: field.disabled, value: field.custom_value, data: {behaviour: 'date-time'}
        when :text
          return f.text_area field.field_name, class: 'normal-input'
        when :single_file_upload
          return f.file_field field.field_name, class: 'normal-input'
        when :multi_file_upload
          return f.file_field field.field_name, multiple: true, class: 'normal-input'
        when :hidden
          return f.hidden_field field.field_name, value: field.custom_value
        end
      end
    end
  end
end
