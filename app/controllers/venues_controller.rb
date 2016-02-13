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
		theatre = Theatre.includes(venue: :owner).where(venues: {"name" => venue_name}, :name => theatre_name)

		if (theatre.length != 1)
			ErrorLogging::log("payments#process_booking", \
												"Selected: " + theatre.length.to_s + " theatres with query")
			flash[:alert] = "I'm sorry but there was a problem processing your request. Please email playogosports@gmail.com for support."
			redirect_to :back
			return
		else
			theatre = theatre.first
		end

		# TODO: verify booking is being made in place of an availability
		# TODO: verify booking is not conflicting with another already made booking
		# TODO: verify that booking has enough time to be approved by manager
		# TODO: make sure two overlapping bookings are being made concurrently

		price = theatre.getPrice(date, start_time, length)

		if (price != amount)
			puts "price:  " + price.to_s
			puts "amount: " + amount.to_s
			flash[:alert] = "I'm sorry but there was a problem processing your request. Please email playogosports@gmail.com for support."
			redirect_to :back
			return
		end
		# if doesn't match: log values and send email to admin

		# Create "pending" booking
		b = Booking.create({:start_time         => start_time, 
							:length             => length, 
							:date               => date, 
							:theatre            => theatre,
							:status             => "no customer",
							:name               => customer_name,
							:customer_address   => customer_address,
							:customer_city      => customer_city,
							:customer_province  => customer_province,
							:customer_country   => customer_country,
							:customer_postal    => customer_postal,
							:phone              => customer_phone,
							:email              => customer_email,
							:notes              => customer_notes,
							:price              => price
							})

		# Error creating the booking
		if (!b)

			error_message  = "Attempt to create a 'no customer' booking failed." + "\n"
			error_message += "name: " + customer_name + "\n"
			error_message += "phone number: " + customer_phone + "\n"
			error_message += "email: " + customer_email + "\n"
			error_message += "venue: " + venue_name + "\n"
			error_message += "theatre: " + theatre_name + "\n"
			error_message += "date: " + params[:date] + "\n"
			error_message += "start time: " + start_time.to_s + "\n"
			error_message += "length: " + length.to_s + "\n"
			ErrorLogging::log("payments#process_booking", error_message)

			flash[:alert] = "I'm sorry but there was a problem requesting that icetime. Please email playogosports@gmail.com for support."
			redirect_to :back
			return

		end


		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		begin

			customer = Stripe::Customer.create(
				card:        token,
				email:       customer_email,
				description: b.id.to_s + ' | ' + \
							 customer_name + ' | ' + \
							 customer_phone + ' | ' + \
							 venue_name + ', ' + \
							 theatre_name + ', ' + \
							 nav_date + ', ' + \
							 start_time.to_s + ', ' + \
							 length.to_s
			)

		# Error creating the customer
		rescue => e
			
			error_message =  "Customer could not be created \n"
			error_message += "name: " + customer_name + "\n"
			error_message += "phone number: " + customer_phone + "\n"
			error_message += "email: " + customer_email + "\n"
			error_message += "venue: " + venue_name + "\n"
			error_message += "theatre: " + theatre_name + "\n"
			error_message += "date: " + params[:date] + "\n"
			error_message += "start time: " + start_time.to_s + "\n"
			error_message += "length: " + length.to_s + "\n"
			ErrorLogging::log("payments#process_booking", error_message)

			# Redirect
			flash[:alert] = "Your card has been declined."
			redirect_to :back
			return

		end

		# Update the booking status to 'pending'
		b.update({:status => "pending", :stripe_customer_id => customer.id})

		flash[:notice] = "Thank you for requesting ice with us. " + theatre.venue.owner.name + " will be confirming your booking within the next " + theatre.venue.owner.processing_hours + " business hours. Check your email inbox for further information."

		# Send manager email
		ManagerMailer.ice_request({:booking_id => b.id, :amount_paid => amount}).deliver_now

		# Send customer email
		CustomerMailer.ice_requested(b.id).deliver_now

		# Notify the admin of confirmation
		AdminMailer.notify_admin({:type => "BOOKING_REQUEST", :booking_id => b.id}).deliver_now

		redirect_to '/venues/?nav_date=' + nav_date + "&postal=" + CGI::escape(nav_postal)
		return
	end

end
