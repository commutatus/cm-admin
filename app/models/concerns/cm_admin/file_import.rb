module CmAdmin::FileImport
  extend ActiveSupport::Concern
  included do
    cm_admin do
      actions only: []
      set_icon 'fa fa-user'
      cm_index do
        page_title 'File Import'
        page_description 'Manage all file import progress here'

        column :id
        column :associated_model_name, header: 'Model Name'
        column :added_by_id, header: 'Added by'

      end

      cm_show page_title: :id do
        tab :profile, '' do
          cm_show_section 'File Import details' do
            field :id, label: 'Import ID'
            field :associated_model_name, label: 'Model Name'
            field :added_by_id
          end
        end

      end
    end
  end
end