class FileImport < ApplicationRecord
  include CmAdmin::FileImport

  belongs_to :added_by, foreign_key: 'added_by_id', class_name: 'User'

  has_one_attached :import_file

  after_create_commit :process_uploaded_file

  def process_uploaded_file
    FileImportProcessorJob.perform_later(self)
  end

end
