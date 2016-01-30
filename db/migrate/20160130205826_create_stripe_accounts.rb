class CreateStripeAccounts < ActiveRecord::Migration
  def change
    create_table :stripe_accounts do |t|
      t.string :account_name
      t.string :live_public_token
      t.string :live_private_token
      t.string :test_public_token
      t.string :test_private_token

      t.timestamps null: false
    end
  end
end
