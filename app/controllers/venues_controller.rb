class VenuesController < ApplicationController
  before_action :set_venue, only: [:show, :edit, :update, :destroy]



  # GET /venues
  # GET /venues.json
  # POST /venues
  def index

    @scheduleTree = Bookable::getBookable

    @ownerInfo = []
    
    Owner.all.each do |owner|
      @ownerInfo.push(owner.getInfo)
    end

    @date = params[:nav_date]

    if !@date

      @date = @scheduleTree.getDayWithAvails(Time.current.to_date.strftime("%Y-%m-%d"))

      params[:nav_date] = @date

    end

    @postal = params[:postal]

    if @postal == nil

      @postal = 'N2G 4G7' # city of kitchener's postal code

    end

  end



  # POST venues/payment
  def ice_booking

    # Params
    token             = params[:stripeToken]
    customer_email    = params[:stripeEmail]
    venue_name        = params[:venue]
    theatre_name      = params[:theatre]
    date              = params[:date]
    start_time        = params[:start_time].to_i
    length            = params[:length].to_i
    amount            = params[:amount].to_i # needs to be verified to be the correct amount
    customer_name     = params[:customer_name]
    customer_address  = params[:customer_address]
    customer_city     = params[:customer_city]
    customer_province = params[:customer_province]
    customer_country  = params[:customer_country]
    customer_postal   = params[:customer_postal]
    customer_phone    = params[:customer_phone]
    customer_notes    = params[:customer_notes]
    nav_date          = params[:nav_date]
    nav_postal        = params[:nav_postal]

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
    # TODO: verify that booking has enough time to be approved by manager

    #theatre.getPrice(date, start_time, length);
    # if doesn't match: log values and send email to admin

    # Create "pending" booking
    b = Booking.create({:start_time        => start_time, 
                        :length            => length, 
                        :date              => date, 
                        :theatre           => theatre,
                        :status            => "pending",
                        :name              => customer_name,
                        :customer_address  => customer_address,
                        :customer_city     => customer_city,
                        :customer_province => customer_province,
                        :customer_country  => customer_country,
                        :customer_postal   => customer_postal,
                        :phone             => customer_phone,
                        :email             => customer_email,
                        :notes             => customer_notes
                        })

    # Error creating the booking
    if (!b)

      error_message  = "Attempt to create a ~pending booking failed." + "\n"
      error_message += "name: " + customer_name + "\n"
      error_message += "phone number: " + customer_phone + "\n"
      error_message += "email: " + customer_email + "\n"
      error_message += "venue: " + venue_name + "\n"
      error_message += "theatre: " + theatre_name + "\n"
      error_message += "date: " + params[:date] + "\n"
      error_message += "start time: " + start_time.to_s + "\n"
      error_message += "length: " + length.to_s + "\n"
      ErrorLogging::log("payments#process_booking", error_message)

      flash[:alert] = "I'm sorry but there was a problem booking that icetime."

      redirect_to '/venues/?date=' + params[:nav_date]

    else
    
      Stripe.api_key = StripeAccount.where(:account_name => "playogosports@gmail.com")[0].getPrivate

      # Charge card
      begin
        charge = Stripe::Charge.create(
          :amount => amount,
          :currency => "cad",
          :source => token,
          :description => b.id.to_s + ' | ' + \
                          customer_name + ' | ' + \
                          customer_phone + ' | ' + \
                          venue_name + ', ' + \
                          theatre_name + ', ' + \
                          nav_date + ', ' + \
                          start_time.to_s + ', ' + \
                          length.to_s
        )

      # Error the card has been declined
      rescue Stripe::CardError => e
        
        error_message =  "Credit card was denied \n"
        error_message += "name: " + customer_name + "\n"
        error_message += "phone number: " + customer_phone + "\n"
        error_message += "email: " + customer_email + "\n"
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
      
      # Error updating the status
      if (!u)
        
        # !important: payment taken without updating status
        error_message =  "Booking status not updated to paid \n"
        error_message += "name: " + customer_name + "\n"
        error_message += "phone number: " + customer_phone + "\n"
        error_message += "email: " + customer_email + "\n"
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

    redirect_to '/venues/?nav_date=' + nav_date + "&postal=" + CGI::escape(nav_postal)

  end



end
