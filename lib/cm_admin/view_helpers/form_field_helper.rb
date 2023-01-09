module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(f, field)
        return unless field.display_if.call(f.object)
        value = field.helper_method ? send(field.helper_method, f.object, field.field_name) : f.object.send(field.field_name)
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
          return f.select field.field_name, options_for_select(select_collection_value(f.object, field), f.object.send(field.field_name)), {include_blank: field.placeholder.to_s}, class: "normal-input #{required_class} select-2", disabled: field.disabled
        when :multi_select
          return f.select field.field_name, options_for_select(select_collection_value(f.object, field), f.object.send(field.field_name)), {include_blank: "Select #{field.field_name.to_s.downcase.gsub('_', ' ')}"}, class: "normal-input #{required_class} select-2", disabled: field.disabled, multiple: true
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
          return f.hidden_field field.field_name, value: value, name: field.html_attr[:name] || "#{f.object_name}[#{field.field_name}]"
        when :check_box
          return f.check_box field.field_name, class: "normal-input cm-checkbox #{required_class}", disabled: field.disabled
        when :radio_button
          format_radio_button_options(value, f)
        end
      end

      # Refactor: Collection argument can be removed.
      # helper_method argument will accept a method where value can be passed.
      def select_collection_value(object, field)
        if field.helper_method
          collection = send(field.helper_method, object, field.field_name)
        elsif field.collection
          collection = field.collection
        else
          collection = []
        end
      end

      def format_radio_button_options(options, f)
        content_tag :div do
          options.each do |val, key|
            concat format_radio_option(val, key, f)
          end
        end
      end
  
      def format_radio_option(val, key, f)
        content_tag :div, class: 'cm-radio-section' do
          concat format_radio_button(val, f)
          concat content_tag(:div, key, class: 'cm-radio-label')
        end
      end

      def format_radio_button(val, f)
        content_tag :div, class: 'cm-radio-tag' do
          concat f.radio_button :level, val, class: "normal-input cm-radio"
        end
      end
    end
  end
end
