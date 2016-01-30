class DropStripeToken < ActiveRecord::Migration
  def change
    drop_table :stripe_tokens
  end
end
