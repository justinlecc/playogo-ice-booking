require 'test_helper'

class VenueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Simple data insert and check" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})

    assert @venue1.valid?
  end

  test "Load and verify venue fields" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    
    assert @venue1.name == "venue1"

  end

  test "Get Bookable icetime - remove start" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 6.hours, :length => 2.hour, :date => '2015-03-01', :theatre => @theatre1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 6.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})

    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @booking1.valid?

    # returns a schedule tree
    schedule = Bookable::getBookable
    iceblock = schedule.venues[0].theatres[0].days[0].blocks[0]

    assert iceblock.start == 7.hours
    assert iceblock.length == 1.hour

  end

  test "Get Bookable icetime - remove end" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 6.hours, :length => 2.hour, :date => '2015-03-01', :theatre => @theatre1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 7.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})

    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @booking1.valid?

    # returns a schedule tree
    schedule = Bookable::getBookable
    iceblock = schedule.venues[0].theatres[0].days[0].blocks[0]

    assert iceblock.start == 6.hours
    assert iceblock.length == 1.hour

  end

  test "Get Bookable icetime - splice" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 10.hours, :length => 10.hour, :date => '2015-03-01', :theatre => @theatre1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 12.hours, :length => 1.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})


    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @booking1.valid?

    # returns a schedule tree
    schedule = Bookable::getBookable

    assert schedule.venues[0].theatres[0].days[0].blocks.length == 2

    iceblock1 = schedule.venues[0].theatres[0].days[0].blocks[0]
    iceblock2 = schedule.venues[0].theatres[0].days[0].blocks[1]

    # CAUTION: test is relying on ordering of blocks which is not guarenteed
    was_start10_length2 = 0
    was_start13_length7 = 0
    if (iceblock1.start == 10.hours) 
      if (iceblock1.length == 2.hours)
        was_start10_length2 = 1
      end
    elsif (iceblock2.start == 13.hours)
      if (iceblock2.length == 7.hours)
        was_start13_length7 = 1
      end
    else
      assert 1 == 2 # fail
    end
    assert was_start10_length2
    assert was_start13_length7

  end

  test "Get Bookable icetime - booking on both sides of opening" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 10.hours, :length => 5.hour, :date => '2015-03-01', :theatre => @theatre1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 9.hours, :length => 2.hour, :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})
    @booking2 = Booking.create!({:start_time => 12.hours, :length => (2.hour + 30.minutes), :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})
    # @booking2 tests edge case of sliver

    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @booking1.valid? && @booking2.valid?

    # returns a schedule tree
    schedule = Bookable::getBookable

    assert schedule.venues[0].theatres[0].days[0].blocks.length == 1

    iceblock = schedule.venues[0].theatres[0].days[0].blocks[0]

    assert iceblock.start == 11.hours
    assert iceblock.length == 1.hour

  end

  test "Get Bookable icetime - booking in middle of two openings" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 10.hours, :length => 2.hour, :date => '2015-03-01', :theatre => @theatre1})
    @opening1 = Opening.create!({:start_time => 14.hours, :length => 3.hour, :date => '2015-03-01', :theatre => @theatre1})
    # Bookings
    @booking1 = Booking.create!({:start_time => 11.hours, :length => (4.hour + 30.minutes), :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})

    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @booking1.valid?

    # returns a schedule tree
    schedule = Bookable::getBookable

    assert schedule.venues[0].theatres[0].days[0].blocks.length == 2

    iceblock1 = schedule.venues[0].theatres[0].days[0].blocks[0]
    iceblock2 = schedule.venues[0].theatres[0].days[0].blocks[1]

    assert iceblock1.start == 10.hours
    assert iceblock1.length == 1.hour
    assert iceblock2.start == (15.hours + 30.minutes)
    assert iceblock2.length == (1.hour + 30.minutes)
  end

  test "Get Bookable icetime - slivers of openings on both sides" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})
    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})
    # Openings
    @opening1 = Opening.create!({:start_time => 10.hours, :length => 2.hour, :date => '2015-03-01', :theatre => @theatre1})
    # Bookings
    @booking1 = Booking.create!({:start_time => (10.hours + 30.minutes), :length => (1.hour), :date => '2015-03-01', :theatre => @theatre1, :name => "Justin Blair", :phone => "3069753958", :email => "justin@playogo.com", :activity_type => "skating party", :notes => "Drinkers will serve time in the penalty box."})

    assert @venue1.valid? && @theatre1.valid? && @opening1.valid? && @booking1.valid?

    # returns a schedule tree
    schedule = Bookable::getBookable

    assert schedule.venues[0].theatres[0].days[0].blocks.length == 0

  end
end
