class CreatePageViews < ActiveRecord::Migration
  def change
    create_table :page_views do |t|
      t.references :viewer, index: true
      t.string :source
      t.string :page

      t.timestamps null: false
    end
    add_foreign_key :page_views, :viewers
  end
end
