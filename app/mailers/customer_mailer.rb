class CustomerMailer < ApplicationMailer
  def ice_requested(booking_id)
    booking = Booking.where({:id => booking_id}).first
    @name = booking.name
    @owner = booking.theatre.venue.owner.name
    @venue = booking.theatre.venue.name
    @theatre = booking.theatre.name
    @date = booking.date
    @start_time = booking.start_time
    @length = booking.length
    email = booking.email

    email = 'playogosports@gmail.com' # testing
    # Send
    mail(:to => email, :subject => 'To customer')
  end

  def ice_confirmed(booking_id)
    booking = Booking.where({:id => booking_id}).first
    @name = booking.name
    @owner = booking.theatre.venue.owner.name
    @venue = booking.theatre.venue.name
    @theatre = booking.theatre.name
    @date = booking.date
    @start_time = booking.start_time
    @length = booking.length
    email = booking.email

    email = 'playogosports@gmail.com' # testing
    # Send
    mail(:to => email, :subject => 'To customer')
  end

end
