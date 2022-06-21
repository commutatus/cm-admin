module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(f, field)
        value = field.custom_value || f.object.send(field.field_name)
        is_required = f.object._validators[field.field_name].map(&:kind).include?(:presence)
        required_class = is_required ? 'required' : ''
        case field.input_type
        when :integer
          return f.text_field field.field_name, class: "normal-input #{required_class}", disabled: field.disabled, value: value, placeholder: "Enter #{field.field_name.to_s.humanize.downcase}", data: { behaviour: 'integer-only' }
        when :decimal
          return f.number_field field.field_name, class: "normal-input #{required_class}", disabled: field.disabled, value: value, placeholder: "Enter #{field.field_name.to_s.downcase.gsub('_', ' ')}", data: { behaviour: 'decimal-only' }
        when :string
          return f.text_field field.field_name, class: "normal-input #{required_class}", disabled: field.disabled, value: value, placeholder: "Enter #{field.field_name.to_s.downcase.gsub('_', ' ')}"
        when :single_select
          return f.select field.field_name, options_for_select(select_collection_value(field), value), {include_blank: "Select #{field.field_name.to_s.downcase.gsub('_', ' ')}"}, class: "normal-input #{required_class} select-2", disabled: field.disabled
        when :multi_select
          return f.select field.field_name, options_for_select(select_collection_value(field), value), {include_blank: "Select #{field.field_name.to_s.downcase.gsub('_', ' ')}"}, class: "normal-input #{required_class} select-2", disabled: field.disabled, multiple: true
        when :date
          return f.text_field field.field_name, class: "normal-input #{required_class}", disabled: field.disabled, value: value&.strftime('%d-%m-%Y'), placeholder: "Enter #{field.field_name.to_s.downcase.gsub('_', ' ')}", data: { behaviour: 'date-only' }
        when :date_time
          return f.text_field field.field_name, class: "normal-input #{required_class}", disabled: field.disabled, value: value, placeholder: "Enter #{field.field_name.to_s.downcase.gsub('_', ' ')}", data: { behaviour: 'date-time' }
        when :text
          return f.text_area field.field_name, class: "normal-input #{required_class}", placeholder: "Enter #{field.field_name.to_s.downcase.gsub('_', ' ')}"
        when :rich_text
          return f.rich_text_area field.field_name, class: "normal-input #{required_class}", placeholder: "Enter #{field.field_name.to_s.downcase.gsub('_', ' ')}"
        when :single_file_upload
          return f.file_field field.field_name, class: "normal-input #{required_class}"
        when :multi_file_upload
          return f.file_field field.field_name, multiple: true, class: "normal-input #{required_class}"
        when :hidden
          return f.hidden_field field.field_name, value: field.custom_value
        end
      end

      def select_collection_value(field)
        if field.collection_method
          collection = send(field.collection_method)
        elsif field.collection
          collection = field.collection
        else
          collection = []
        end
      end
    end
  end
end
