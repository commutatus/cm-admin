require_relative 'form_field_helper'
module CmAdmin
  module ViewHelpers
    module FormHelper
      include FormFieldHelper
      REJECTABLE = %w(id created_at updated_at)

      def generate_form(resource, cm_model)
        if resource.new_record?
          action = :new
          method = :post
        else
          action = :edit
          method = :patch
        end
        if cm_model.available_fields[action].empty?
          return form_with_all_fields(resource, method)
        else
          return form_with_mentioned_fields(resource, cm_model.available_fields[action], method)
        end
      end

      def form_with_all_fields(resource, method)
        columns = resource.class.columns.dup
        table_name = resource.model_name.collection
        columns.reject! { |i| REJECTABLE.include?(i.name) }
        url = CmAdmin::Engine.mount_path + "/#{table_name}/#{resource.id}"
        set_form_for_fields(resource, columns, url, method)
      end

      def form_with_mentioned_fields(resource, available_fields, method)
        # columns = resource.class.columns.select { |i| available_fields.map(&:field_name).include?(i.name.to_sym) }
        table_name = resource.model_name.collection
        # columns.reject! { |i| REJECTABLE.include?(i.name) }
        url = CmAdmin::Engine.mount_path + "/#{table_name}/#{resource.id}"
        set_form_for_fields(resource, available_fields, url, method)
      end

      def set_form_for_fields(resource, available_fields_hash, url, method)
        form_for(resource, url: url, method: method, html: { class: "cm_#{resource.class.name.downcase}_form" } ) do |f|
          if params[:referrer]
            concat f.text_field "referrer", class: "normal-input", hidden: true, value: params[:referrer], name: 'referrer'
          end
          if params[:polymorphic_name].present?
            concat f.text_field params[:polymorphic_name] + '_type', class: "normal-input", hidden: true, value: params[:associated_class].classify
            concat f.text_field params[:polymorphic_name] + '_id', class: "normal-input", hidden: true, value: params[:associated_id]
          elsif params[:associated_class] && params[:associated_id]
            concat f.text_field params[:associated_class] + '_id', class: "normal-input", hidden: true, value: params[:associated_id]
          end
          available_fields_hash.each do |key, fields_array|
            if key == :fields
              fields_array.each do |field|
                next unless field.display_if.call(f.object)
                if field.input_type.eql?(:hidden)
                  concat input_field_for_column(f, field)
                else
                  concat(content_tag(:div, class: "input-wrapper #{field.disabled ? 'disabled' : ''}") do
                    concat f.label field.label, field.label, class: "field-label"
                    concat tag.br
                    concat(content_tag(:div, class: "datetime-wrapper") do
                      concat input_field_for_column(f, field)
                    end)
                    concat tag.p resource.errors[field.field_name].first if resource.errors[field.field_name].present?
                  end)
                end
              end
            else
              concat(render partial: '/cm_admin/main/nested_table_form', locals: {f: f, table_name: key})
            end
          end
          concat tag.br
          concat f.submit 'Save', class: 'cta-btn mt-3 form_submit', data: {form_class: "cm_#{f.object.class.name.downcase}_form"}
        end
      end
    end
  end
end
