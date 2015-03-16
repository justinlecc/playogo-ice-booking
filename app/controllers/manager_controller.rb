class ManagerController < ApplicationController

  def respond_to_request
    booking_id = params[:booking_id]
    booking = Booking.where({:id => booking_id}).first

    if (booking == nil || booking.status != "paid")
      redirect_to '/venues'
      return
    end

    @booking_id = booking.id

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


  def confirm_request
    # TO DO: make params safe
    booking_id = params[:booking_id]
    theatre_id = params[:theatre]
    date_str = params[:date]
    start_time_str = params[:start_time]
    end_time_str = params[:end_time]
    contract_id = params[:contract_id]

    # TO DO: verify form of date and time strings

    # Get booking
    booking = Booking.where(:id => booking_id).first
    if (!booking || booking.status != "paid")
      # TO DO: handle this error
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
      throw "ERROR: start_time isn't before endtime"
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
    end

    # Notify the customer
    CustomerMailer.ice_confirmed(booking.id).deliver_now

    redirect_to '/venues'
  end

  def cancel_request
    booking_id = params[:booking_id]
    booking = Booking.where({:id => booking_id}).first
    booking.update!({:status => "cancelled"})

    # TO DO: handle what happens when booking cancelled
    # -refund
    # -email customer? (municipalities job to contact them)

    redirect_to '/venues'
  end 
end
