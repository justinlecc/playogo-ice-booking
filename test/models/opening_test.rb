require 'test_helper'

class OpeningTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Simple data insert and check" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})

    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})

    # Openings
    @opening1 = Opening.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1})

    assert @venue1.valid? && @theatre1.valid? && @opening1.valid?
  end

  test "Load and verify opening fields" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1})
    
    assert @venue1.valid? && @theatre1.valid? && @opening1.valid?

    assert @theatre1.openings.first.date == '2015-03-01'
    assert @theatre1.openings.first.start_time == 6.hours
    assert @theatre1.openings.first.length == 1.hours
    assert @theatre1.openings.first.end_time == 7.hours
  end

  test "Load and verify opening number of openings" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1})
    @opening2 = Opening.create!({:start_time => 22.hours, :length => 2.hour, :date => '2015-03-01', :theatre => @theatre1})
    @opening3 = Opening.create!({:start_time => 7.hours, :length => 8.hour, :date => '2015-03-01', :theatre => @theatre1})
    
    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @opening2.valid? && @opening3.valid?
    assert @theatre1.openings.length == 3

  end
end
