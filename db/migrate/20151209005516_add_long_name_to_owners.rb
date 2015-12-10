class AddLongNameToOwners < ActiveRecord::Migration
  def change
    add_column :owners, :long_name, :string
  end
end
