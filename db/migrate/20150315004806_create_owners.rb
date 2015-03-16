class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :name
      t.string :manager_name
      t.string :manager_email

      t.timestamps null: false
    end
  end
end
