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

      def form_with_mentioned_fields(resource, entities, method)
        # columns = resource.class.columns.select { |i| available_fields.map(&:field_name).include?(i.name.to_sym) }
        table_name = resource.model_name.collection
        # columns.reject! { |i| REJECTABLE.include?(i.name) }
        url = CmAdmin::Engine.mount_path + "/#{table_name}/#{resource.id}"
        set_form_with_sections(resource, entities, url, method)
      end

      def split_form_into_section(resource, form_obj, entities)
        content_tag :div do
          entities.each do |entity|
            if entity.class == CmAdmin::Models::Row
              concat create_rows(resource, form_obj, entity)
            elsif entity.class == CmAdmin::Models::Section
              concat(content_tag(:div, class: 'row') do
                concat create_sections(resource, form_obj, entity)
              end)
            end
          end
        end
      end

      def create_rows(resource, form_obj, row)
        content_tag :div, class: 'row' do
          row.sections.each do |section|
            concat create_sections(resource, form_obj, section)
          end
        end
      end

      def create_sections(resource, form_obj, section)
        content_tag :div, class: 'col form-container' do
          concat content_tag(:p, section.section_name, class: 'form-title')
          concat set_form_for_fields(resource, form_obj, section)
        end
      end

      def create_row_inside_section(resource, form_obj, rows)
        rows.each do |row|
          concat(content_tag(:div, class: 'row') do
            row.row_fields.each do |field|
              concat set_form_field(resource, form_obj, field)
            end
          end)
        end
        return
      end

      def set_form_for_fields(resource, form_obj, section)
        content_tag(:div, class: 'form-container__inner') do
          concat create_row_inside_section(resource, form_obj, section.rows) if section.rows.present?
          concat set_form_fields(resource, form_obj, section.section_fields)
          concat set_nested_form_fields(form_obj, section)
        end
      end

      def set_form_fields(resource, form_obj, fields)
        fields.each do |field|
          concat(content_tag(:div, class: 'row') do
            concat set_form_field(resource, form_obj, field)
          end)
        end
        return
      end

      def set_form_field(resource, form_obj, field)
        content_tag(:div, class: field.col_size ? "col-#{field.col_size}" : 'col') do
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
      end

      def set_nested_form_fields(form_obj, section)
        content_tag(:div) do
          section.nested_table_fields.keys.each do |key|
            concat(render partial: '/cm_admin/main/nested_table_form', locals: { f: form_obj, assoc_name: key, section: section })
          end
        end
      end

      def set_form_with_sections(resource, entities, url, method)
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
          concat split_form_into_section(resource, form_obj, entities)
          concat tag.br
           # TODO: form_submit class is used for JS functionality, Have to remove 
          concat form_obj.submit 'Save', class: 'btn-cta mt-3 form_submit', data: {form_class: "cm_#{form_obj.object.class.name.downcase}_form"}
        end
      end
    end
  end
end
