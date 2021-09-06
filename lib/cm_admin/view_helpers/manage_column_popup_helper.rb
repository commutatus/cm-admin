module CmAdmin
  module ViewHelpers
    module ManageColumnPopupHelper

      def manage_column_pop_up(klass)
        tag.div class: 'modal fade form-modal table-column-modal', id: 'columnActionModal', role: 'dialog', aria: {labelledby: 'exampleModalLabel'} do
          tag.div class: 'modal-dialog', role: 'document' do
            tag.div class: 'modal-content' do
              tag.div do
                concat manage_column_header
                concat manage_column_body(klass)
                concat manage_column_footer
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
          concat tag.h5 'Manage columns', class: 'modal-title', id: 'exampleModalLabel'
        end)
        return
      end

      def manage_column_body(klass)
        tag.div class: 'modal-body' do
          tag.div class: 'columns-list' do
            klass.available_fields[:index].each do |column_name|
              concat manage_column_body_list(column_name)
            end
          end
        end
      end

      def manage_column_body_list(column_name)
        tag.div class: 'column-item' do
          concat manage_column_dragger(column_name.field_name)
          concat manage_column_item_name(column_name)
          concat manage_column_item_pointer(column_name.field_name)
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

      def manage_column_item_pointer(default_column_name)
        tag.div class: "column-item__action #{'pointer' if default_column_name != :id}" do
          tag.i class: "fa #{default_column_name == :id ? 'fa-lock' : 'fa-times-circle'} bolder"
        end
      end

      def manage_column_footer
        concat(content_tag(:div, class: 'modal-footer') do
          concat tag.button 'Close', class: 'gray-border-btn', data: {bs_dismiss: 'modal'}
          concat tag.button 'Save', class: 'cta-btn'
        end)
        return
      end
    end
  end
end
