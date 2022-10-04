require "webpacker/helper"

module CmAdmin
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      CmAdmin.webpacker
    end

    # Allow if policy is not defined.
    def has_valid_policy(model_name, action_name)
      return true unless policy([:cm_admin, model_name.classify.constantize]).methods.include?(:"#{action_name}?")
      policy([:cm_admin, model_name.classify.constantize]).send(:"#{action_name}?")
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
      content_tag(:div) do
        invalid_rows = model_name.send(field_name)
        concat error_header
        concat error_items(invalid_rows)
      end
    end

    def error_header
      content_tag :div, class: 'info-split' do
        concat content_tag(:div, "Row number", class: 'info-split__lhs')
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
      content_tag :div, class: 'info-split' do
        concat content_tag(:div, row_item[0], class: 'info-split__lhs')
        concat format_error(row_item[2])
      end
    end

    def format_error(errors)
      content_tag :div do
        errors.each do |error|
          concat content_tag(:div, error[0].titleize + '-' + error[1])
        end
      end
    end
  end
end
