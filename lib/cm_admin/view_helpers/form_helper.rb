require_relative 'form_field_helper'
module CmAdmin
  module ViewHelpers
    module FormHelper
      include FormFieldHelper
      REJECTABLE = %w(id created_at updated_at)

      def generate_edit_form(resource, cm_model)
        if cm_model.available_fields[:edit].empty?
          return edit_form_with_all_fields(resource)
        else
          return edit_form_with_mentioned_fields(resource, cm_model.available_fields[:edit])
        end
      end

      def edit_form_with_all_fields(resource)
        columns = resource.class.columns.dup
        columns.reject! { |i| REJECTABLE.include?(i.name) }
        url, method = ["/admin/blogs/#{resource.id}", :patch]
        set_form_for_fields(resource, columns, url, method)
      end

      def edit_form_with_mentioned_fields(resource, available_fields)
        columns = resource.class.columns.select { |i| available_fields.include?(i.name.to_sym) }
        columns.reject! { |i| REJECTABLE.include?(i.name) }
        url, method = ["/admin/blogs/#{resource.id}", :patch]
        set_form_for_fields(resource, columns, url, method)
      end

      def set_form_for_fields(resource, columns, url, method)
        form_for(resource, url: url, method: method) do |f|
          columns.each do |field|
            concat f.label field.name
            concat tag.br
            concat input_field_for_column(f, field)
            concat tag.br
            concat tag.br
          end
          concat tag.br
          concat f.submit 'Save'
        end
      end
    end
  end
end
