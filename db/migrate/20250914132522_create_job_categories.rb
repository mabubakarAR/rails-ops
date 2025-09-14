class CreateJobCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :job_categories do |t|
      t.references :job, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
