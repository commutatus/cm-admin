module CmAdmin
  module ApplicationHelper

    def current_webpacker_instance
      CmAdmin.webpacker
    end

    # Allow if policy is not defined.
    def has_valid_policy(ar_object, action_name)
      if ar_object.instance_of?(OpenStruct) && ar_object&.parent_record.present? && ar_object&.associated_model.present?
        policy_object = ar_object.parent_record
        associated_model = ar_object.associated_model

        policy_instance = "CmAdmin::#{associated_model}Policy".constantize.new(:cm_admin, policy_object)

        return true unless policy_instance.methods.include?(:"#{action_name}?")

        policy_instance.send(:"#{action_name}?")
      else
        policy_object = ar_object.instance_of?(OpenStruct) ? @model.name.classify.constantize : ar_object

        return true unless policy([:cm_admin, policy_object]).methods.include?(:"#{action_name}?")

        policy([:cm_admin, policy_object]).send(:"#{action_name}?")
      end
    end

    def action(action_name)
      case action_name.to_sym
      when :update
        return :edit
      when :create
        return :new
      else
        return action_name.to_sym
      end
    end

    def formatted_error_message(model_name, field_name)
      invalid_rows = model_name.send(field_name)
      if invalid_rows.present?
        content_tag(:div) do
          concat error_header
          concat error_items(invalid_rows)
        end
      end
    end

    def error_header
      content_tag :div, class: 'card-info' do
        concat content_tag(:div, "Row number", class: 'card-info__label')
        concat content_tag(:div, "Error")
      end
    end

    def error_items(invalid_rows)
      content_tag :div do
        invalid_rows.each do |row_item|
          concat format_error_item(row_item)
        end
      end
    end

    def format_error_item(row_item)
      content_tag :div, class: 'info-point' do
        concat content_tag(:div, row_item[0], class: 'card-info__label')
        concat format_error(row_item[2])
      end
    end

    def format_error(errors)
      content_tag :div do
        errors.each do |error|
          message = error[1].instance_of?(Array) ? error[1].join(', ') : error[1]
          concat content_tag(:div, error[0].titleize + '-' + message)
        end
      end
    end

    def is_show_action_available(model, ar_object)

      model &&
      model.available_actions.map(&:name).include?('show') &&
      has_valid_policy(ar_object, 'show')
    end

    def actions_filter(model, ar_object, action_type)
      model.available_actions.select { |action| action.action_type == action_type && has_valid_policy(ar_object, action.name) }
    end
  end
end
