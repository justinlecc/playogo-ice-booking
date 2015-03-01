class ChangeDateFormatInBooking < ActiveRecord::Migration
  def up
    change_column :bookings, :date, :string
  end

  def down
    change_column :bookings, :date, :date
  end
end
