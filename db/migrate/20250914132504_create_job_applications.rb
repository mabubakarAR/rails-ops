class CreateJobApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :job_applications do |t|
      t.text :cover_letter
      t.string :status
      t.datetime :applied_at
      t.references :job, null: false, foreign_key: true
      t.references :job_seeker, null: false, foreign_key: true

      t.timestamps
    end
  end
end
