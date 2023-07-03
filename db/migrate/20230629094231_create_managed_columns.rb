class CreateManagedColumns < ActiveRecord::Migration[7.0]
  def change
    create_table :managed_columns do |t|
      t.integer :user_id
      t.string :table_name
      t.jsonb :arranged_columns

      t.timestamps
    end
  end
end
