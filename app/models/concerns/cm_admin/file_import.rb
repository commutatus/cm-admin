module CmAdmin::FileImport
  extend ActiveSupport::Concern
  included do
    cm_admin do
      STATUS_TAG_COLOR = { in_progress: 'active-two', success: 'completed', failed: 'danger' }
      actions only: [:index, :show]
      set_icon 'fa fa-file-upload'
      cm_index do
        page_title 'File Import'
        page_description 'Manage all file import progress here'

        filter [:id, :associated_model_name], :search, placeholder: 'ID, Table Name'
        filter :status, :single_select,
               collection: %w[in_progress success failed],
               placeholder: 'Status'
        filter :created_at, :date, placeholder: 'Created At'

        column :id
        column :imported_file_name, header: 'File'
        column :created_at, header: 'Created At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
        column :status, field_type: :tag, tag_class: STATUS_TAG_COLOR
        column :associated_model_name, header: 'Table name'
        column :added_by_name, header: 'Uploaded By'

      end

      cm_show page_title: :id do
        tab :profile, '' do
          cm_show_section 'Import details' do
            field :id, label: 'Import ID'
            field :import_file, label: 'File', field_type: :attachment
            field :created_at, header: 'Created At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
            field :completed_at, header: 'Completed At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
            field :associated_model_name, header: 'Table name'
            field :added_by_name, header: 'Uploaded By'
            field :status, field_type: :tag, tag_class: STATUS_TAG_COLOR
          end
          cm_show_section 'Errors' do
            field :invalid_row_items, field_type: :custom, helper_method: :formatted_error_message
          end
        end

      end
    end
  end
end
