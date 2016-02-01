class AddProcessingHoursToOwners < ActiveRecord::Migration
  def change
    add_column :owners, :processing_hours, :string
  end
end
