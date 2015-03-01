require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Simple data insert and check" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})

    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})

    # Bookings
    @booking1 = Booking.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})

    assert @venue1.valid? && @theatre1.valid? && @booking1.valid?
  end

  test "Load and verify booking fields" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})
    
    assert @venue1.valid? && @theatre1.valid? && @booking1.valid?
    assert @theatre1.bookings.first.date == '2015-03-01'
    assert @theatre1.bookings.first.start_time == 6.hours
    assert @theatre1.bookings.first.length == 1.hours
    assert @theatre1.bookings.first.end_time == 7.hours
  end

  test "Load and verify number of bookings" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})
    @booking2 = Booking.create!({:start_time => 7.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})
    @booking3 = Booking.create!({:start_time => 9.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})
    
    assert @venue1.valid? && @theatre1.valid? && @booking1.valid? && @booking2.valid? && @booking3.valid?

    assert @theatre1.bookings.length == 3

  end
end
