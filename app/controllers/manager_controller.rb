class ManagerController < ApplicationController

  # Serves page manager will confirm or cancel a pending booking
  def respond_to_request
    @booking_id = params[:booking_id]
    booking = Booking.where({:id => @booking_id}).first

    if (booking == nil || booking.status != "pending")
      flash[:alert] = "I'm sorry but that booking page does not exist. Please contact PlayogoSports@gmail.com for support."
      redirect_to '/venues'
      return
    end

    # Booking info
    @booking_venue = booking.theatre.venue.name
    @booking_theatre = booking.theatre.name
    @date = booking.date
    @start_time = booking.start_time
    @length = booking.length

    # Owner info (in case of booking change)
    owner = booking.theatre.venue.owner
    @owner = owner.name
    @venues = Hash.new { |hash, key| hash[key] = []}
    owner.venues.each do |venue|
      venue.theatres.each do |theatre|
        @venues[venue.name].push({:name => theatre.name, :id => theatre.id})
      end
    end
  end

  # Manager confirmed the booking
  def confirm_request
    # TODO: make params safe
    booking_id     = params[:booking_id]
    theatre_id     = params[:theatre]
    date_str       = params[:date]
    start_time_str = params[:start_time]
    end_time_str   = params[:end_time]
    contract_id    = params[:contract_id]

    # TO DO: verify form of date and time strings

    # Get booking
    booking = Booking.where(:id => booking_id).first
    if (!booking || booking.status != "pending")
      # TO DO: handle this error
      flash[:alert] = "This booking is no longer pending. Please email playogosports@gmail.com for support."
      redirect_to '/venues'
      return
    end

    # Parse startime
    start_time_obj = Time.zone.parse(start_time_str)
    if (start_time_obj < Time.zone.parse("4:00am")) # time is after midnight !Assumes 4am is between day bookings
      new_start_time = (start_time_obj - Time.zone.parse("12:00am")).round + 24.hours
    else
      new_start_time = (start_time_obj - Time.zone.parse("12:00am")).round
    end

    # Parse length
    end_time_obj = Time.zone.parse(end_time_str)
    if (end_time_obj < Time.zone.parse("4:00am"))
      new_end_time = (end_time_obj - Time.zone.parse("12:00am")).round + 24.hours
    else
      new_end_time = (end_time_obj - Time.zone.parse("12:00am")).round
    end

    if (new_end_time <= new_start_time)
      flash[:alert] = "The specified start time of the booking was not before the end time. Please try again or email playogosports@gmail.com for support."
      redirect_to '/venues'
      return
    end

    new_length = new_end_time - new_start_time

    # Compare new values to the old values
    if (date_str == booking.date \
     && new_start_time == booking.start_time \
     && new_length == booking.length \
     && theatre_id == booking.theatre.id)

      # If all fields match, update status
      booking.update!({:status => "confirmed", :contract_id => contract_id})

    else

      # Else update fields
      theatre = Theatre.where({:id => theatre_id}).first
      booking.update!({:start_time => new_start_time,
                       :length => new_length,
                       :theatre => theatre,
                       :date => date_str,
                       :status => "confirmed",
                       :contract_id => contract_id
                      })
      new_price = booking.getPrice
      booking.update!({:price => new_price})

    end

  
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    begin

      # Charge the customer
      Stripe::Charge.create(
          amount: booking.price,
          currency: 'cad',
          customer: booking.stripe_customer_id
      )

    # Error creating the customer
    rescue => e
      
      error_message =  "Customer could not be charged \n"
      error_message += "name: " + booking.name + "\n"
      error_message += "phone number: " + booking.phone + "\n"
      error_message += "email: " + booking.email + "\n"
      error_message += "venue: " + booking.theatre.venue.name + "\n"
      error_message += "theatre: " + booking.theatre.name + "\n"
      error_message += "date: " + params[:date] + "\n"
      error_message += "start time: " + booking.start_time.to_s + "\n"
      error_message += "length: " + length.to_s + "\n" 
      error_message += "amount: " + booking.getPrice + "\n" 
      ErrorLogging::log("payments#process_booking", error_message)

      # Redirect
      flash[:alert] = "The customer's card could not be charged. Please email playogosports@gmail.com for support."
      redirect_to '/venues'
      return

    end

    booking.update!({:status => "paid"})

    # Notify the customer
    CustomerMailer.ice_confirmed(booking.id).deliver_now

    # Notify the admin of confirmation
    AdminMailer.notify_admin({:type => "BOOKING_CONFIRMATION", :booking_id => booking_id}).deliver_now

    flash[:notice] = "Thank you for confirming the booking. The customer has been notified and is waiting for you to follow up with them."
    redirect_to '/venues'

  end

  # Manager cancels booking
  def cancel_request
    booking_id = params[:booking_id]
    booking = Booking.where({:id => booking_id}).first
    booking.update!({:status => "cancelled"})

    # TO DO: handle what happens when booking cancelled
    # -refund
    # -email customer? (municipalities job to contact them)

    # Notify admin of cancellation
    AdminMailer.notify_admin({:type => "BOOKING_CANCELLATION", :booking_id => booking_id}).deliver_now

    flash[:notice] = "Thank you for processing the booking request. Please be sure you have followed up with the customer. If you did not mean to cancel this booking, please email playogosports@gmail.com for support."
    redirect_to '/venues'
  end 
end
