module CmAdmin
  module ViewHelpers
    module FormFieldHelper
      def input_field_for_column(form_obj, cm_field)
        return unless cm_field.display_if.call(form_obj.object)

        value = cm_field.helper_method ? send(cm_field.helper_method, form_obj.object, cm_field.field_name) : form_obj.object.send(cm_field.field_name)
        is_required = form_obj.object._validators[cm_field.field_name].map(&:kind).include?(:presence)
        required_class = is_required ? 'required' : ''
        target_action = @model.available_actions.select { |x| x.name == cm_field.target[:action_name].to_s }.first if cm_field.target.present?
        send("cm_#{cm_field.input_type}_field", form_obj, cm_field, value, required_class, target_action)
      end

      def cm_integer_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.text_field cm_field.field_name,
                            class: "normal-input #{required_class}",
                            disabled: cm_field.disabled,
                            value: value,
                            placeholder: cm_field.placeholder,
                            data: { behaviour: 'integer-only' }
      end

      def cm_decimal_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.number_field cm_field.field_name,
                              class: "normal-input #{required_class}",
                              disabled: cm_field.disabled,
                              value: value,
                              placeholder: cm_field.placeholder,
                              data: { behaviour: 'decimal-only' }
      end

      def cm_string_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.text_field cm_field.field_name,
                            class: "normal-input #{required_class}",
                            disabled: cm_field.disabled,
                            value: value,
                            placeholder: cm_field.placeholder
      end

      def cm_single_select_field(form_obj, cm_field, value, required_class, target_action)
        form_obj.select cm_field.field_name, options_for_select(select_collection_value(form_obj.object, cm_field), form_obj.object.send(cm_field.field_name)),
                        { include_blank: cm_field.placeholder },
                        class: "normal-input #{required_class} select-2",
                        disabled: cm_field.disabled,
                        data: {
                          field_name: cm_field.field_name,
                          field_type: 'linked-field',
                          target_action: target_action&.name,
                          target_url: target_action&.name ? cm_admin.send("#{@model.name.underscore}_#{target_action&.name}_path") : ''
                        }
      end

      def cm_multi_select_field(form_obj, cm_field, value, required_class, target_action)
        form_obj.select cm_field.field_name,
                        options_for_select(select_collection_value(form_obj.object, cm_field), form_obj.object.send(cm_field.field_name)),
                        { include_blank: cm_field.placeholder },
                        class: "normal-input #{required_class} select-2",
                        disabled: cm_field.disabled, multiple: true
      end

      def cm_date_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.text_field cm_field.field_name,
                            class: "normal-input #{required_class}",
                            disabled: cm_field.disabled,
                            value: value&.strftime('%d-%m-%Y'),
                            placeholder: cm_field.placeholder,
                            data: { behaviour: 'date-only' }
      end

      def cm_date_time_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.text_field cm_field.field_name,
                            class: "normal-input #{required_class}",
                            disabled: cm_field.disabled,
                            value: value,
                            placeholder: cm_field.placeholder,
                            data: { behaviour: 'date-time' }
      end

      def cm_text_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.text_area cm_field.field_name,
                           class: "normal-input #{required_class}",
                           placeholder: cm_field.placeholder
      end

      def cm_rich_text_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.rich_text_area cm_field.field_name,
                                class: "normal-input #{required_class}",
                                placeholder: cm_field.placeholder
      end

      def cm_single_file_upload_field(form_obj, cm_field, _value, required_class, _target_action)
        form_obj.file_field cm_field.field_name, class: "normal-input #{required_class}"
      end

      def cm_multi_file_upload_field(form_obj, cm_field, _value, required_class, _target_action)
        form_obj.file_field cm_field.field_name, multiple: true, class: "normal-input #{required_class}"
      end

      def cm_check_box_field(form_obj, cm_field, value, required_class, target_action)
        format_check_box_options(value, form_obj, cm_field, required_class, target_action)
      end

      def cm_radio_button_field(form_obj, cm_field, value, required_class, _target_action)
        format_radio_button_options(value, form_obj)
      end

      def cm_hidden_field(form_obj, cm_field, value, required_class, _target_action)
        form_obj.hidden_field cm_field.field_name,
                              value: value,
                              name: cm_field.html_attr[:name] || "#{form_obj.object_name}[#{cm_field.field_name}]"
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

      def format_check_box_options(value, form_obj, cm_field, required_class, target_action)
        if value.instance_of?(Array)
          format_check_box_array(value, form_obj, cm_field, required_class, target_action)
        else
          form_obj.check_box cm_field.field_name,
                             {
                               class: "normal-input cm-checkbox #{required_class} #{target_action.present? ? 'linked-field-request' : ''}",
                               disabled: cm_field.disabled,
                               data: {
                                 field_name: cm_field.field_name,
                                 target_action: target_action&.name,
                                 target_url: target_action&.name ? cm_admin.send("#{@model.name.underscore}_#{target_action&.name}_path") : ''
                               }
                             }
        end
      end

      def format_check_box_array(options, form_obj, cm_field, required_class, target_action)
        content_tag :div do
          options.each do |key, val|
            concat format_check_box(val, key, form_obj, cm_field, required_class, target_action)
          end
        end
      end

      def format_check_box(val, key, form_obj, cm_field, required_class, target_action)
        content_tag :div, class: 'cm-checkbox-section' do
          concat format_check_box_tag(val, form_obj, cm_field, required_class, target_action)
          concat content_tag(:div, key, class: 'cm-checkbox-label')
        end
      end

      def format_check_box_tag(val, form_obj, cm_field, required_class, target_action)
        content_tag :div, class: 'cm-radio-tag' do
          concat form_obj.check_box cm_field.field_name,
                                    {
                                      class: "normal-input cm-checkbox #{required_class} #{target_action.present? ? 'linked-field-request' : ''}",
                                      disabled: cm_field.disabled,
                                      name: "#{@model.name.underscore}[#{cm_field.field_name}][]",
                                      data: {
                                        target_action: target_action&.name,
                                        target_url: target_action&.name ? cm_admin.send("#{@model.name.underscore}_#{target_action&.name}_path", ':param_1') : ''
                                      }
                                    }, val
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
