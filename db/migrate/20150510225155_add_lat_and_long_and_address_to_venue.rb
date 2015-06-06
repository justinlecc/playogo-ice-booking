class AddLatAndLongAndAddressToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :lat, :float
    add_column :venues, :long, :float
    add_column :venues, :address, :string
  end
end
