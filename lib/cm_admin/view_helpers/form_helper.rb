require_relative 'form_field_helper'
module CmAdmin
  module ViewHelpers
    module FormHelper
      include FormFieldHelper
      REJECTABLE = %w(id created_at updated_at)

      def generate_edit_form(resource, cm_model)
        if resource.new_record?
          action = :new
          method = :post
        else
          action = :edit
          method = :patch
        end
        if cm_model.available_fields[action].empty?
          return edit_form_with_all_fields(resource, method)
        else
          return edit_form_with_mentioned_fields(resource, cm_model.available_fields[:edit], method)
        end
      end

      def edit_form_with_all_fields(resource, method)
        columns = resource.class.columns.dup
        table_name = resource.class.table_name
        columns.reject! { |i| REJECTABLE.include?(i.name) }
        url = CmAdmin::Engine.mount_path + "/#{table_name}/#{resource.id}"
        set_form_for_fields(resource, columns, url, method)
      end

      def edit_form_with_mentioned_fields(resource, available_fields, method)
        columns = resource.class.columns.select { |i| available_fields.include?(i.name.to_sym) }
        table_name = resource.class.table_name
        columns.reject! { |i| REJECTABLE.include?(i.name) }
        url = CmAdmin::Engine.mount_path + "/#{table_name}/#{resource.id}"
        set_form_for_fields(resource, columns, url, method)
      end

      def set_form_for_fields(resource, columns, url, method)
        form_for(resource, url: url, method: method) do |f|
          columns.each do |field|
            concat f.label field.name, class: 'field-label'
            concat tag.br
            concat input_field_for_column(f, field)
            concat tag.br
            concat tag.br
          end
          concat tag.br
          concat f.submit 'Save', class: 'cta-btn mt-3'
        end
      end
    end
  end
end
