class AddCustomerCityToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_city, :string
  end
end
