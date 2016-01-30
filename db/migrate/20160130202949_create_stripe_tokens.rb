class CreateStripeTokens < ActiveRecord::Migration
  def change
    create_table :stripe_tokens do |t|
      t.string :version
      t.string :type
      t.string :value
      t.string :account

      t.timestamps null: false
    end
  end
end
