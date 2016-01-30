class AddCustomerCountryToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_country, :string
  end
end
