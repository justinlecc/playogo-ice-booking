class AddCustomerPostalToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_postal, :string
  end
end
