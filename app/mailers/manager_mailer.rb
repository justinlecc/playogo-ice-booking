class ManagerMailer < ApplicationMailer
  default from: "justin_leclerc@hotmail.com"
  # layout 'mailer'

  # Email sent to manager requesting the booking (booking_id) be confirmed
  def ice_request(info)

    # Formatter
    formatter = DateTimeFormatter.new

    # Get booking
    booking_id = info[:booking_id]
    booking    = Booking.where({:id => booking_id})
    if (booking.length != 1)
      throw "ERROR: booking_id not recognized in mailer"
    end
    booking = booking.first

    # Get owner
    owner = booking.theatre.venue.owner

    # Booking info
    @date       = formatter.shortToMidDateStr(booking.date) #daylight savings?
    @start_time = formatter.secondsToTimeStr(booking.start_time)
    @end_time   = formatter.secondsToTimeStr(booking.start_time + booking.length)
    @venue      = booking.theatre.venue.name
    @theatre    = booking.theatre.name
    @activity   = booking.activity_type
    @amount     = info[:amount_paid]

    # Manager info
    @manager_name  = owner.manager_name
    @manager_email = owner.manager_email

    # Customer info
    @customer_name  = booking.name
    @customer_email = booking.email
    @customer_phone = booking.phone
    @customer_notes = booking.notes

    # Booking id
    @booking_id = booking.id

    # Send
    mail(:to => @manager_email, :subject => 'Ice Booking')
    
  end
end
