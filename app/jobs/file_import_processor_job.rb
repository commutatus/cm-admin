class FileImportProcessorJob < ApplicationJob
  queue_as :default

  def perform(file_import)
    model = CmAdmin::Model.find_by({name: file_import.associated_model_name})
    path = ActiveStorage::Blob.service.path_for(file_import.import_file.key)
    import = model.importer.class_name.classify.constantize.new(path: path)
    if import.valid_header?
      import.run!
      if import.report.success?
        file_import.update(status: :success, completed_at: DateTime.now)
      else
        invalid_items_array = import.report.invalid_rows.map { |row| [row.line_number, row.model.email, row.errors] }
        file_import.update(status: :failed, completed_at: DateTime.now, invalid_row_items: invalid_items_array)
      end
    else
      puts 'Invalid header'
    end
  end
end
