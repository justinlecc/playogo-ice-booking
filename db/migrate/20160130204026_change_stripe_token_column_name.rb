class ChangeStripeTokenColumnName < ActiveRecord::Migration
  def change
    rename_column :stripe_tokens, :type, :token_type
  end
end
