class CreateOpenings < ActiveRecord::Migration
  def change
    create_table :openings do |t|
      t.integer :start_time
      t.integer :length
      t.string :date
      t.references :theatre, index: true

      t.timestamps null: false
    end
    add_foreign_key :openings, :theatres
  end
end
