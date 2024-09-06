class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.references :company, null: false, foreign_key: true
      t.string :location
      t.decimal :salary

      t.timestamps
    end
  end
end
