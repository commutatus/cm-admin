class FileImportProcessorJob < ApplicationJob
  queue_as :default

  def perform(file_import)
    model = CmAdmin::Model.find_by({name: file_import.associated_model_name})
    path = ActiveStorage::Blob.service.path_for(file_import.import_file.key)
    import = model.importer.class_name.classify.constantize.new(path: path)
    if import.valid_header?
      import.run!
      if import.report.success?
        puts 'Successful import'
      else
        byebug
        puts 'Error while import'
        puts import.report.invalid_rows
      end
    else
      puts 'Invalid header'
    end
  end
end
