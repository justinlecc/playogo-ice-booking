class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :prime
      t.integer :non_prime
      t.integer :insurance
      t.references :theatre, index: true

      t.timestamps null: false
    end
    add_foreign_key :prices, :theatres
  end
end
