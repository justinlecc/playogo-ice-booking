class VenuesController < ApplicationController
  before_action :set_venue, only: [:show, :edit, :update, :destroy]



  # GET /venues
  # GET /venues.json
  # POST /venues
  def index

    @date = params[:nav_date]
    if !@date
      @date = Date.current.strftime("%Y-%m-%d")
      params[:nav_date] = @date
    end

    @postal = params[:postal]
    if @postal == nil
      @postal = 'N2H 1Z6' # the aud's postal code
    end

    #scheduleTree = ScheduleTree.new("Playogo")

    @scheduleTree = Bookable::getBookable

  end



  # POST venues/payment
  def ice_booking 
    # Params !! Protect against injection attack !!
    token        = params[:stripeToken]
    email        = params[:stripeEmail]
    venue_name   = params[:venue]
    theatre_name = params[:theatre]
    date         = params[:date]
    start_time   = params[:start_time].to_i
    length       = params[:length].to_i
    amount       = params[:amount].to_i # needs to be verified to be the correct amount
    name         = params[:name]
    phone_number = params[:phone]
    notes        = params[:notes]
    nav_date     = params[:nav_date]
    nav_postal   = params[:nav_postal]

    # Get the theatre
    theatre = Theatre.joins(:venue).where(venues: {"name" => venue_name}, :name => theatre_name)

    if (theatre.length != 1)
      ErrorLogging::log("payments#process_booking", \
                        "Selected: " + theatre.length.to_s + " theatres with query")
      raise "ERROR: Invalid theatre query in venue controller"
    else
      theatre = theatre.first
    end

    # TODO: verify booking is being made in place of an availability
    # TODO: verify booking is not conflicting with another already made booking
    # TODO: verify that 'amount' is the correct amount of money for the booking

    # Create "pending" booking
    b = Booking.create({:start_time => start_time, 
                        :length => length, 
                        :date => date, 
                        :theatre => theatre,
                        :status => "pending",
                        :name => name,
                        :phone => phone_number,
                        :email => email,
                        :notes => notes
                        })

    if (!b)
      # Error creating the booking
      ErrorLogging::log("payments#process_booking", \
                        "Attempt to create a ~pending booking failed.")
      flash[:notice] = "I'm sorry but there was a problem booking that icetime."
      redirect_to '/venues/?date=' + params[:nav_date]
    else
      # Charge card
      Stripe.api_key = "sk_test_nEHfNS9vf7MqoUWM5KzRDf9M"

      begin
        charge = Stripe::Charge.create(
          :amount => amount,
          :currency => "cad",
          :source => token,
          :description => name + ' | ' + \
                          phone_number + ' | ' + \
                          venue_name + ', ' + \
                          theatre_name + ', ' + \
                          nav_date + ', ' + \
                          start_time.to_s + ', ' + \
                          length.to_s
        )
      rescue Stripe::CardError => e
        # Error the card has been declined
        error_message =  "Credit card was denied \n"
        error_message += "name: " + name + "\n"
        error_message += "phone number: " + phone_number + "\n"
        error_message += "email: " + email + "\n"
        error_message += "venue: " + venue_name + "\n"
        error_message += "theatre: " + theatre_name + "\n"
        error_message += "date: " + params[:date] + "\n"
        error_message += "start time: " + start_time.to_s + "\n"
        error_message += "length: " + length.to_s + "\n"
        ErrorLogging::log("payments#process_booking", error_message)

        # Delete booking
        b.delete 

        # Redirect
        flash[:notice] = "Your card has been declined."
        redirect_to :back
      end
      
      flash[:notice] = "Thank you for booking ice with us. Check your email inbox for further information."


      # Update to "paid" booking
      u = b.update({:status => "paid"})
      
      if (!u)
        # Error updating the status
        # !important: payment taken without updating status
        error_message =  "Booking status not updated to paid \n"
        error_message += "name: " + name + "\n"
        error_message += "phone number: " + phone_number + "\n"
        error_message += "email: " + email + "\n"
        error_message += "venue: " + venue_name + "\n"
        error_message += "theatre: " + theatre_name + "\n"
        error_message += "date: " + params[:date] + "\n"
        error_message += "start time: " + start_time.to_s + "\n"
        error_message += "length: " + length.to_s + "\n"
        ErrorLogging::log("payments#process_booking", error_message)
      end

    end

    # Send manager email
    ManagerMailer.ice_request({:booking_id => b.id, :amount_paid => amount}).deliver_now

    # Send customer email
    CustomerMailer.ice_requested(b.id).deliver_now

    # Notify the admin of confirmation
    AdminMailer.notify_admin({:type => "BOOKING_REQUEST", :booking_id => b.id}).deliver_now

    redirect_to '/venues/?nav_date=' + nav_date + "&postal=" + nav_postal
  end



end
