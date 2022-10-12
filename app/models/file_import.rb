class FileImport < ApplicationRecord
  include CmAdmin::FileImport

  belongs_to :added_by, polymorphic: true

  enum status: { in_progress: 0, success: 1, failed: 2 }

  has_one_attached :import_file

  after_create_commit :process_uploaded_file

  store_accessor :error_report, :invalid_row_items


  def process_uploaded_file
    FileImportProcessorJob.perform_later(self)
  end

  def imported_file_name
    import_file.filename.to_s
  end

  def added_by_name
    added_by.first_name
  end

end
