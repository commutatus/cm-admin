class FileImportProcessorJob < ApplicationJob
  queue_as :default

  def perform(file_import)
    model = CmAdmin::Model.find_by({name: file_import.associated_model_name})
    path = ActiveStorage::Blob.service.path_for(file_import.import_file.key)
    importer = model.importer.class_name.classify.constantize.new(path: path)
    case model.importer.importer_type.to_s
    when 'csv_importer'
      run_csv_importer(importer, file_import)
    when 'custom_importer'
      run_custom_importer(importer, file_import)
    end
  end

  # All logic are from csv_importer gem
  def run_csv_importer(importer, file_import)
    if importer.valid_header?
      importer.run!
      if importer.report.success?
        file_import.update(status: :success, completed_at: DateTime.now)
      else
        identifier = importer.config.identifiers.first
        invalid_items_array = importer.report.invalid_rows.map { |row| [row.line_number, row.model.send(identifier), row.errors] }
        file_import.update(status: :failed, completed_at: DateTime.now, invalid_row_items: invalid_items_array)
      end
    else
      byebug
      file_import.update(status: :failed, completed_at: DateTime.now, invalid_row_items: [[1, 'invalid_header', {invalid_header: importer.report.message}]])
    end
  end

  def run_custom_importer(importer, file_import)
    importer.run!
    invalid_items_array = importer.invalid_rows.map { |row| [row.line_number, row.identifier, row.errors] }
    status = importer.invalid_rows.empty? ? :success : :failed
    file_import.update(status: status, completed_at: DateTime.now, invalid_row_items: invalid_items_array)
  end
end
