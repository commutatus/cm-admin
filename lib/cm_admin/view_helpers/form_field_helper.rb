module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(form_obj, cm_field)
        return unless cm_field.display_if.call(form_obj.object)

        value = cm_field.helper_method ? send(cm_field.helper_method, form_obj.object, cm_field.field_name) : form_obj.object.send(cm_field.field_name)
        is_required = form_obj.object._validators[cm_field.field_name].map(&:kind).include?(:presence)
        required_class = is_required ? 'required' : ''
        target_action = @model.available_actions.select{|x| x.name == cm_field.target[:action_name].to_s}.first if cm_field.target.present?
        case cm_field.input_type
        when :integer
          form_obj.text_field cm_field.field_name, class: "normal-input #{required_class}", disabled: cm_field.disabled, value: value, placeholder: "Enter #{cm_field.field_name.to_s.humanize.downcase}", data: { behaviour: 'integer-only' }
        when :decimal
          form_obj.number_field cm_field.field_name, class: "normal-input #{required_class}", disabled: cm_field.disabled, value: value, placeholder: "Enter #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}", data: { behaviour: 'decimal-only' }
        when :string
          form_obj.text_field cm_field.field_name, class: "normal-input #{required_class}", disabled: cm_field.disabled, value: value, placeholder: "Enter #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}"
        when :single_select
          form_obj.select cm_field.field_name, options_for_select(select_collection_value(form_obj.object, cm_field), form_obj.object.send(cm_field.field_name)),
                          { include_blank: cm_field.placeholder.to_s },
                          class: "normal-input #{required_class} select-2 #{target_action.present? ? 'linked-field-request' : ''}",
                          disabled: cm_field.disabled,
                          data: { target_action: target_action&.name, target_url: target_action&.name ? cm_admin.send(@model.name.underscore + '_' + target_action&.name + '_path', ':param_1') : '' }
        when :multi_select
          form_obj.select cm_field.field_name, options_for_select(select_collection_value(form_obj.object, cm_field), form_obj.object.send(cm_field.field_name)), {include_blank: "Select #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}"}, class: "normal-input #{required_class} select-2", disabled: cm_field.disabled, multiple: true
        when :date
          form_obj.text_field cm_field.field_name, class: "normal-input #{required_class}", disabled: cm_field.disabled, value: value&.strftime('%d-%m-%Y'), placeholder: "Enter #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}", data: { behaviour: 'date-only' }
        when :date_time
          form_obj.text_field cm_field.field_name, class: "normal-input #{required_class}", disabled: cm_field.disabled, value: value, placeholder: "Enter #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}", data: { behaviour: 'date-time' }
        when :text
          form_obj.text_area cm_field.field_name, class: "normal-input #{required_class}", placeholder: "Enter #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}"
        when :rich_text
          form_obj.rich_text_area cm_field.field_name, class: "normal-input #{required_class}", placeholder: "Enter #{cm_field.field_name.to_s.downcase.gsub('_', ' ')}"
        when :single_file_upload
          form_obj.file_field cm_field.field_name, class: "normal-input #{required_class}"
        when :multi_file_upload
          form_obj.file_field cm_field.field_name, multiple: true, class: "normal-input #{required_class}"
        when :hidden
          form_obj.hidden_field cm_field.field_name, value: value, name: cm_field.html_attr[:name] || "#{form_obj.object_name}[#{cm_field.field_name}]"
        when :check_box
          format_check_box_options(value, form_obj, cm_field, required_class)
        when :radio_button
          format_radio_button_options(value, form_obj)
        end
      end
      

      # Refactor: Collection argument can be removed.
      # helper_method argument will accept a method where value can be passed.
      def select_collection_value(object, cm_field)
        if cm_field.helper_method
          collection = send(cm_field.helper_method, object, cm_field.field_name)
        elsif cm_field.collection
          collection = cm_field.collection
        else
          collection = []
        end
      end

      def format_check_box_options(value, form_obj, cm_field, required_class)
        if value.class == Array
          format_check_box_array(value, form_obj, cm_field, required_class)
        else
          form_obj.check_box cm_field.field_name, class: "normal-input cm-checkbox #{required_class}", disabled: cm_field.disabled
        end
      end

      def format_check_box_array(options, form_obj, cm_field, required_class)
        content_tag :div do
          options.each do |key, val|
            concat format_check_box(val, key, form_obj, cm_field, required_class)
          end
        end
      end

      def format_check_box(val, key, form_obj, cm_field, required_class)
        content_tag :div, class: 'cm-checkbox-section' do
          concat format_check_box_tag(val, form_obj, cm_field, required_class)
          concat content_tag(:div, key, class: 'cm-checkbox-label')
        end
      end

      def format_check_box_tag(val, form_obj, cm_field, required_class)
        content_tag :div, class: 'cm-radio-tag' do
          concat form_obj.check_box cm_field.field_name, { class: "normal-input cm-checkbox #{required_class}", disabled: cm_field.disabled, name: "#{@model.name.underscore}[#{cm_field.field_name}][]" }, val
        end
      end


      def format_radio_button_options(options, form_obj)
        content_tag :div do
          options.each do |val, key|
            concat format_radio_option(val, key, form_obj)
          end
        end
      end
  
      def format_radio_option(val, key, form_obj)
        content_tag :div, class: 'cm-radio-section' do
          concat format_radio_button(val, form_obj)
          concat content_tag(:div, key, class: 'cm-radio-label')
        end
      end

      def format_radio_button(val, form_obj)
        content_tag :div, class: 'cm-radio-tag' do
          concat form_obj.radio_button :level, val, class: 'normal-input cm-radio'
        end
      end
    end
  end
end
