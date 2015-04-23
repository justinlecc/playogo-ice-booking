class VenuesController < ApplicationController
  before_action :set_venue, only: [:show, :edit, :update, :destroy]



  # GET /venues
  # GET /venues.json
  def index
    # handle params[:nav_date]
    @date = params[:nav_date]
    if !@date
      @date = Date.current.strftime("%Y-%m-%d")
    end  

    @venues = Venue.all

    scheduleTree = ScheduleTree.new("Playogo")

    @scheduleTree = Bookable::getBookable

  end



  # POST venues/payment
  def ice_booking 
    # Params !! Protect against injection attack !!
    token = params[:stripeToken]
    email = params[:stripeEmail]
    venue_name = params[:venue]
    theatre_name = params[:theatre]
    date = params[:date]
    start_time = params[:start_time].to_i
    length = params[:length].to_i
    amount = params[:amount].to_i
    name = params[:name]
    phone_number = params[:phone]
    notes = params[:notes]

    # Get the theatre
    theatre = Theatre.joins(:venue).where(venues: {"name" => venue_name}, :name => theatre_name)

    if (theatre.length != 1)
      ErrorLogging::log("payments#process_booking", \
                        "Selected: " + theatre.length.to_s + " theatres with query")
      raise "ERROR: Invalid theatre query in venue controller"
    end
    theatre = theatre.first

    # TO DO: verify that booking is being made in place of an availability

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
          :description => "JL testing stripe charges."
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
      flash[:notice] = "Thank you for booking ice with us."


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
    # ManagerMailer.ice_request(b.id).deliver_now

    # Send customer email
    # CustomerMailer.ice_requested(b.id).deliver_now

    redirect_to '/venues/?date=' + params[:nav_date]
  end


  ########################################
  # THE FOLLOWING ACTIONS ARE NOT NEEDED #
  ########################################

  # POST /venues
  # POST /venues.json
  def create
    @venue = Venue.new(venue_params)

    respond_to do |format|
      if @venue.save
        format.html { redirect_to @venue, notice: 'Venue was successfully created.' }
        format.json { render :show, status: :created, location: @venue }
      else
        format.html { render :new }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /venues/1
  # PATCH/PUT /venues/1.json
  def update
    respond_to do |format|
      if @venue.update(venue_params)
        format.html { redirect_to @venue, notice: 'Venue was successfully updated.' }
        format.json { render :show, status: :ok, location: @venue }
      else
        format.html { render :edit }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue.destroy
    respond_to do |format|
      format.html { redirect_to venues_url, notice: 'Venue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_venue
      @venue = Venue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def venue_params
      params.require(:venue).permit(:name)
    end
end
