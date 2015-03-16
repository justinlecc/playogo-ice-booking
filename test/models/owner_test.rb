require 'test_helper'

class OwnerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Simple insert and test fields" do
    drop_all

    @owner1 = Owner.create!({:name => "owner1", :manager_name => "Allison", :manager_email => "ali@kitch.ca"})
    # Venues
    @venue1 = Venue.create!({:name => "venue1", :owner => @owner1})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})

    assert @venue1.valid? && @theatre1.valid? && @owner1.valid?

    assert @owner1.name == "owner1"
    assert @owner1.venues.first.name == "venue1"
    assert @venue1.owner.manager_name == "Allison"

  end
end
