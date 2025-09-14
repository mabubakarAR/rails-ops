class CreateJobSeekers < ActiveRecord::Migration[7.2]
  def change
    create_table :job_seekers do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :location
      t.text :bio
      t.text :skills
      t.integer :experience_years
      t.string :resume
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
