class AddStripeCustomerIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :stripe_customer_id, :string
  end
end
