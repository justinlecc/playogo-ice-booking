class CustomerMailer < ApplicationMailer

  # Confirmation that the booking (booking_id) has been logged and we are waiting for rink manager to respond
  def ice_requested(booking_id)

    formatter = DateTimeFormatter.new

    booking = Booking.where({:id => booking_id}).first

    @name       = booking.name
    @owner      = booking.theatre.venue.owner.name
    @venue      = booking.theatre.venue.name
    @theatre    = booking.theatre.name
    @date       = formatter.shortToMidDateStr(booking.date)
    @start_time = formatter.secondsToTimeStr(booking.start_time)
    @end_time   = formatter.secondsToTimeStr(booking.end_time)
    email       = booking.email

    email = 'playogosports@gmail.com' # testing

    # Send
    mail(:to => email, :subject => 'To customer')
  end

  # Booking (booking_id) has been confirmed by the rink manager
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
