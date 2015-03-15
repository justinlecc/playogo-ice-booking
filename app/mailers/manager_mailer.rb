class ManagerMailer < ApplicationMailer
  default from: "justin_leclerc@hotmail.com"
  # layout 'mailer'
  def ice_request
    # Will be param
    booking_id = Booking.first.id

    # Get booking
    booking = Booking.where({:id => booking_id})
    if (booking.length != 1)
      throw "ERROR: booking_id not recognized in mailer"
    end
    booking = booking.first

    # Booking info
    @date = Date.parse(booking.date)
    @start_time = booking.start_time
    @end_time = booking.end_time
    @length = booking.length
    @venue = booking.theatre.venue.name
    @theatre = booking.theatre.name
    @activity = booking.activity_type

    # Manager info
    @manager_name = 'Ashley'
    @manager_email = 'justin_leclerc@hotmail.com'

    # Customer info
    @customer_name = booking.name
    @customer_email = booking.email
    @customer_phone = booking.phone
    @customer_notes = booking.notes



    mail(:to => @manager_email, :subject => 'Welcome to My Awesome Site')
  end
end
