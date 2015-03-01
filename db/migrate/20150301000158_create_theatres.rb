class CreateTheatres < ActiveRecord::Migration
  def change
    create_table :theatres do |t|
      t.string :name
      t.references :venue, index: true

      t.timestamps null: false
    end
    add_foreign_key :theatres, :venues
  end
end
