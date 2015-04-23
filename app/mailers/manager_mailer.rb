class ManagerMailer < ApplicationMailer
  default from: "justin_leclerc@hotmail.com"
  # layout 'mailer'

  def ice_request(booking_id)

    # Get booking
    booking = Booking.where({:id => booking_id})
    if (booking.length != 1)
      throw "ERROR: booking_id not recognized in mailer"
    end
    booking = booking.first

    # Get owner
    owner = booking.theatre.venue.owner

    # Booking info
    @date = Date.parse(booking.date) #daylight savings?
    @start_time = booking.start_time
    @length = booking.length
    @venue = booking.theatre.venue.name
    @theatre = booking.theatre.name
    @activity = booking.activity_type

    # Manager info
    @manager_name = owner.manager_name
    @manager_email = owner.manager_email

    # Customer info
    @customer_name = booking.name
    @customer_email = booking.email
    @customer_phone = booking.phone
    @customer_notes = booking.notes

    # Booking id
    @booking_id = booking.id

    # Send
    mail(:to => @manager_email, :subject => 'To manager')
    
  end
end
