module CmAdmin
  module ViewHelpers
    module ManageColumnPopupHelper
      include FormFieldHelper

      def manage_column_pop_up(klass)
        tag.div class: 'modal fade form-modal table-column-modal', id: 'columnActionModal', role: 'dialog' do
          tag.div class: 'modal-dialog', role: 'document' do
            tag.div class: 'modal-content' do
              tag.div do
                concat manage_column_header
                concat manage_column_body(klass)
              end
            end
          end
        end
      end

      def manage_column_header
        concat(content_tag(:div, class: 'modal-header') do
          concat(content_tag(:button, class: 'close', data: {bs_dismiss: 'modal'}) do
            tag.span 'X'
          end)
          concat tag.h5 'Manage columns', class: 'modal-title'
        end)
        return
      end

      def manage_column_body(klass)
        form_for(ManagedColumn.new, url: cm_admin.send("#{@model.name.underscore}_manage_column_path"), method: :post, html: { class: "managed-column-form" } ) do |form_obj|
          concat form_obj.hidden_field :table_name, value: @model.name.underscore
          concat body_detail(form_obj, klass)
          concat manage_column_footer(form_obj)
        end
      end

      def body_detail(form_obj, klass)
        tag.div class: 'modal-body' do
          tag.div class: 'columns-list' do
            managed_column = ManagedColumn.where(user_id: Current.user.id, table_name: @model.name.underscore).first
            @ordered_columns.each do |column_name|
              concat manage_column_body_list(column_name, form_obj, managed_column)
            end
          end
        end
      end

      def manage_column_body_list(column_name, form_obj, managed_column)
        tag.div class: 'column-item' do
          concat manage_column_dragger(column_name.field_name)
          concat manage_column_item_name(column_name)
          concat manage_column_item_pointer(column_name, form_obj, managed_column)
        end
      end

      def manage_column_dragger(default_column_name)
        return if default_column_name == :id
        tag.div class: 'dragger' do
          tag.i class: 'fa fa-bars bolder'
        end
      end

      def manage_column_item_name(column_name)
        tag.div class: 'column-item__name' do
          tag.p column_name.field_name.to_s.gsub('/', '_').humanize
        end
      end

      def manage_column_item_pointer(column_name, form_obj, managed_column)
        tag.div class: "column-item__action #{'pointer' if column_name.field_name != :id}" do
          column_hash = managed_column&.arranged_columns&.dig('column_list')&.select{ |hash| hash['column_name'] == column_name.field_name.to_s }&.first
          concat form_obj.check_box 'sorted_columns', { class: 'normal-input cm-checkbox hidden', multiple: true, checked: true }, column_name.field_name, nil
          concat form_obj.check_box 'enabled_columns', { class: 'normal-input cm-checkbox', multiple: true, checked: column_hash&.dig('is_enabled') }, column_name.field_name, nil
          # tag.i class: "fa #{column_name.field_name == :id ? 'fa-lock' : 'fa-times-circle'} bolder"
        end
      end

      def manage_column_footer(form_obj)
        concat(content_tag(:div, class: 'modal-footer') do
          concat tag.button 'Close', class: 'gray-border-btn', data: {bs_dismiss: 'modal'}
          # concat tag.button 'Save', class: 'cta-btn'
          concat form_obj.submit 'Save', class: 'cta-btn', data: {form_class: "cm_#{form_obj.object.class.name.downcase}_form"}
        end)
        return
      end
    end
  end
end
