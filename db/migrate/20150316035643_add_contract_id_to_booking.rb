class AddContractIdToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :contract_id, :string
  end
end
