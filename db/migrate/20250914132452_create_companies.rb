class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :description
      t.string :website
      t.string :industry
      t.string :size
      t.integer :founded_year
      t.string :headquarters
      t.string :logo
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
