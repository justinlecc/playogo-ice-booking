class AddCustomerProvinceToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_province, :string
  end
end
