class AddCustomerAddressToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_address, :string
  end
end
