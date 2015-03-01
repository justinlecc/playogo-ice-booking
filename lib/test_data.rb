class TestData

  def deleteData
    Booking.delete_all
    Opening.delete_all
    Theatre.delete_all
    Venue.delete_all
  end

  def loadData
    deleteData

    # Venues
    @venue1 = Venue.create!({:name => "venue1"})

    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})

    # Openings
    @opening1 = Opening.create!({:start_time => 12.hours, :length => 5.hour, :date => '2015-03-01', :theatre => @theatre1})

    # Bookings
    @booking1 = Booking.create!({:start_time => 11.hours, :length => 5.hour, :date => '2015-03-01', :theatre => @theatre1})
    if !@venue1.valid? || !@theatre1.valid? || !@opening1.valid? || !@booking1.valid?
      raise "ERROR: Data insert invalid in TestData.loadTestData"
    end

  end
end