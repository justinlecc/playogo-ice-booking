class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.date :date
      t.integer :start_time
      t.integer :length
      t.string :name
      t.string :phone
      t.string :email
      t.string :notes
      t.string :activity_type
      t.references :theatre, index: true

      t.timestamps null: false
    end
    add_foreign_key :bookings, :theatres
  end
end
