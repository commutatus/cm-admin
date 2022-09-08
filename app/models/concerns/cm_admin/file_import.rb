module CmAdmin::FileImport
  extend ActiveSupport::Concern
  included do
    cm_admin do
      actions only: [:index, :show]
      set_icon 'fa fa-user'
      cm_index do
        page_title 'File Import'
        page_description 'Manage all file import progress here'

        column :id
        column :imported_file_name, header: 'File'
        column :created_at, header: 'Started At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
        column :completed_at, header: 'Completed At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
        column :associated_model_name, header: 'Model name'
        column :added_by_id, header: 'Uploaded By'
        column :status
      end

      cm_show page_title: :id do
        tab :profile, '' do
          cm_show_section 'Import details' do
            field :id, label: 'Import ID'
            field :imported_file_name, label: 'File'
            field :created_at, header: 'Started At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
            field :completed_at, header: 'Completed At', field_type: :datetime, format: '%B %d, %Y, %H:%M %p'
            field :associated_model_name, header: 'Model name'
            field :added_by_id, header: 'Uploaded By'
            field :status
          end
          cm_show_section 'Errors' do
            field :invalid_row_items, field_type: :custom, helper_method: :formatted_error_message
          end
        end

      end
    end
  end
end