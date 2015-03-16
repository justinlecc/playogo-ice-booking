class AddOwnerRefsToVenue < ActiveRecord::Migration
  def change
    add_reference :venues, :owner
  end
end
