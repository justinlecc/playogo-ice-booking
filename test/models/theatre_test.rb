require 'test_helper'

class TheatreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Simple data insert and check" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    

    assert @venue1.valid? && @theatre1.valid?
  end

  test "Load and verify theatre fields" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    
    assert @theatre1.name == "theatre1"
    assert @theatre1.venue.name == "venue1"

  end

end
