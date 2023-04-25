class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.references :item, foreign_key: true
      t.references :parent, foreign_key: true
      t.date :due_date
      t.boolean :completion
      t.string :status

      t.timestamps
    end
  end
end
