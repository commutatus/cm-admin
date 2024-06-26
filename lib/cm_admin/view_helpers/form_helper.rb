require_relative 'form_field_helper'
require 'cgi'
require 'uri'

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
              next unless entity.display_if.call(form_obj.object)

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
            next unless section.display_if.call(form_obj.object)

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
            concat(content_tag(:div, class: "form-field #{field.disabled ? 'disabled' : ''}") do
              concat form_obj.label field.label, field.label, class: 'field-label'
              concat tag.br
              concat input_field_for_column(form_obj, field)
              concat tag.p resource.errors[field.field_name].first if resource.errors[field.field_name].present?
            end)
          end
        end
      end

      def set_nested_form_fields(form_obj, section)
        content_tag(:div) do
          section.nested_table_fields.each do |nested_table_field|
            concat(render partial: '/cm_admin/main/nested_table_form', locals: { f: form_obj, nested_table_field: nested_table_field })
          end
        end
      end

      def set_form_with_sections(resource, entities, url, method)
        url_with_query_params = extract_query_params(url)

        form_for(resource, url: url_with_query_params || url, method: method, html: { class: "cm_#{resource.class.name.downcase}_form" } ) do |form_obj|
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
          concat form_obj.submit 'Save', class: 'btn-cta', data: {behaviour: 'form_submit', form_class: "cm_#{form_obj.object.class.name.downcase}_form"}
        end
      end


      def extract_query_params(url)
        query_params = {}
        if params[:polymorphic_name].present? || params[:associated_id].present? && params[:associated_class].present?
          query_params[:polymorphic_name] = params[:polymorphic_name]
          query_params[:associated_id] = params[:associated_id]
          query_params[:associated_class] = params[:associated_class]
          query_params[:referrer] = params[:referrer] if params[:referrer].present?

          return url + '?' + query_params.to_query unless query_params.empty?
        end
      end
    end
  end
end
