class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.text :requirements
      t.text :benefits
      t.string :location
      t.decimal :salary_min
      t.decimal :salary_max
      t.string :employment_type
      t.boolean :remote
      t.string :status
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
