class CreateFileImport < ActiveRecord::Migration[6.1]
  def change
    create_table :file_imports do |t|
      t.string :associated_model_name
      t.references :added_by, polymorphic: true, null: false
      t.jsonb :error_report
      t.datetime :completed_at
      t.integer :status

      t.timestamps
    end
  end
end
