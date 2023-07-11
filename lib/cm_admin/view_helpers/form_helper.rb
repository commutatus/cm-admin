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

      def form_with_mentioned_fields(resource, sections_array, method)
        # columns = resource.class.columns.select { |i| available_fields.map(&:field_name).include?(i.name.to_sym) }
        table_name = resource.model_name.collection
        # columns.reject! { |i| REJECTABLE.include?(i.name) }
        url = CmAdmin::Engine.mount_path + "/#{table_name}/#{resource.id}"
        set_form_with_sections(resource, sections_array, url, method)
      end

      def split_form_into_section(resource, form_obj, sections_array)
        content_tag :div do
          sections_array.each do |section|
            concat create_sections(resource, form_obj, section)
          end
        end
      end

      def create_sections(resource, form_obj, section)
        content_tag :div, class: 'form-container' do
          concat content_tag(:p, section.section_name, class: 'form-title')
          concat set_form_for_fields(resource, form_obj, section)
        end
      end

      def set_form_for_fields(resource, form_obj, section)
        content_tag(:div, class: 'form-container__inner') do
          section.section_fields.each do |field|
            next unless field.display_if.call(form_obj.object)

            if field.input_type.eql?(:hidden)
              concat input_field_for_column(form_obj, field)
            else
              concat(content_tag(:div, class: "input-wrapper #{field.disabled ? 'disabled' : ''}") do
                concat form_obj.label field.label, field.label, class: 'field-label'
                concat tag.br
                concat(content_tag(:div, class: 'datetime-wrapper') do
                  concat input_field_for_column(form_obj, field)
                end)
                concat tag.p resource.errors[field.field_name].first if resource.errors[field.field_name].present?
              end)
            end
          end
          concat set_nested_form_fields(form_obj, section)
        end
      end

      def set_nested_form_fields(form_obj, section)
        content_tag(:div) do
          section.nested_table_fields.keys.each do |key|
            concat(render partial: '/cm_admin/main/nested_table_form', locals: { f: form_obj, assoc_name: key, section: section })
          end
        end
      end

      def set_form_with_sections(resource, sections_array, url, method)
        form_for(resource, url: url, method: method, html: { class: "cm_#{resource.class.name.downcase}_form" } ) do |form_obj|
          if params[:referrer]
            concat form_obj.text_field "referrer", class: "normal-input", hidden: true, value: params[:referrer], name: 'referrer'
          end
          if params[:polymorphic_name].present?
            concat form_obj.text_field params[:polymorphic_name] + '_type', class: "normal-input", hidden: true, value: params[:associated_class].classify
            concat form_obj.text_field params[:polymorphic_name] + '_id', class: "normal-input", hidden: true, value: params[:associated_id]
          elsif params[:associated_class] && params[:associated_id]
            concat form_obj.text_field params[:associated_class] + '_id', class: "normal-input", hidden: true, value: params[:associated_id]
          end
          concat split_form_into_section(resource, form_obj, sections_array)
          concat tag.br
          concat form_obj.submit 'Save', class: 'cta-btn mt-3 form_submit', data: {form_class: "cm_#{form_obj.object.class.name.downcase}_form"}
        end
      end
    end
  end
end
