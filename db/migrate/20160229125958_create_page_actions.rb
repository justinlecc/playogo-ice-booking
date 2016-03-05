class CreatePageActions < ActiveRecord::Migration
  def change
    create_table :page_actions do |t|
      t.references :page_view, index: true
      t.string :action

      t.timestamps null: false
    end
    add_foreign_key :page_actions, :page_views
  end
end
