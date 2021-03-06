'use strict'

/////////////////////////////////////////////////////////////////////////
// TODO: Put into definitions file. Will need to be dynamic to accomedate more provinces.
var TAX_RATE = .13;



/////////////////////////////////////////////////////////////////////////
// Controller

function createControllerModule () {
    /*
     * Controller states (explanation of each below)
     */
    var SEARCH         = 'SEARCH';
    var TIME_SELECT    = 'TIME_SELECT';
    var VENUE_POLICIES = 'VENUE_POLICIES';
    var INPUT_INFO     = 'INPUT_INFO';
    var REVIEW_INFO    = 'REVIEW_INFO';
    var PAYMENT        = 'PAYMENT';

    /*
     * Event types
     */
    var DATE_UPDATE = 'DATE_UPDATE';


    /*
     * Controller for the venues page
     */
    var VenueController = function (availsCollectionModel, availsScheduleModel, mapModel, scheduleRenderer, useTracker) {

        // Initialize controller listeners
        this.listeners = [];

        // Initialize models
        this.availsCollectionModel = availsCollectionModel;
        this.availsScheduleModel   = availsScheduleModel;
        this.mapModel              = mapModel;
        this.useTracker            = useTracker;

        // Initialize renderers
        this.scheduleRenderer      = scheduleRenderer;
        this.listeners.push(this.scheduleRenderer.notify);

        // Listen to models
        var self = this;
        this.availsScheduleModel.addListener(self.notify);
        this.mapModel.addListener(self.notify);

    };

    _.extend(VenueController.prototype, {

        /*
         *  Initialize controller
         */
        initializePage: function () {
            // Controller reference
            var self = this;

            // Get values from template
            var nav_date      = document.getElementById('nav-date').innerHTML;
            var postal        = document.getElementById('postal').innerHTML;
            var schedule_tree = JSON.parse(document.getElementById('schedule-tree').innerHTML);
            var owner_info    = JSON.parse(document.getElementById('owner-info').innerHTML);

            // Set avails in collection model
            this.availsCollectionModel.setAvails(schedule_tree); 
            this.availsCollectionModel.setOwners(owner_info);

            // Set range, date
            this.availsScheduleModel.setDateRange(this.availsCollectionModel.getAvails());
            this.availsScheduleModel.setCurrentDate(nav_date); // for testing, should initialize actual date

            // Set postal code
            this.mapModel.setPostal(postal);

            // Render page
            this.scheduleRenderer.renderAll(this.availsScheduleModel.getCurrentDate(), this.mapModel.getPostal(), this.availsCollectionModel.getAvails(), self);

            // Rerender page if browser resized 
            // Debouncing makes render triggered x milliseconds after last window resize (http://underscorejs.org/#throttle)
            // TODO: Does rerendering need to make another request to google maps?
            var debouncedRenderAll = _.debounce(self.scheduleRenderer.renderAll, 500).bind(self.scheduleRenderer); 
            window.addEventListener("resize", function() {
                debouncedRenderAll(self.availsScheduleModel.getCurrentDate(), self.mapModel.getPostal(), self.availsCollectionModel.getAvails(), self);
            });


            // Page flow state. Mainly used for modal flow logic.
            // States:
            //   1. SEARCH - Looking through possible availabilities
            //   2. TIME_SELECT - Specifying a start and end of a timeslot
            //   3. VENUE_POLICIES - Reading terms and conditions of booking
            //   4. INPUT_INFO - Filling out customer information fields
            //   5. PAYMENT - Paying for specified booking
            this.page_state = SEARCH;

            // Customer info
            // TODO: this needs to go into a model
            this.customer_name            = '';
            this.customer_address         = '';
            this.customer_city            = '';
            this.customer_province        = '';
            this.customer_country         = '';
            this.customer_postal          = '';
            this.customer_phone           = '';
            this.customer_notes           = '';

            // Avail info
            // TODO: this needs to go into a model
            this.selected_owner_id        = '';
            this.selected_venue           = '';
            this.selected_theatre         = '';
            this.selected_prime           = '';
            this.selected_non_prime       = '';
            this.selected_insurance       = '';
            this.selected_date            = '';
            this.selected_start_time      = '';
            this.selected_length          = '';

            // Booking info
            // TODO: this needs to go into a model
            this.specified_start_time     = '';
            this.specified_length         = '';
            this.specified_price          = '';
            this.specified_insurance_cost = '';
            this.specified_tax            = '';
            this.specified_total_cost     = '';

            // Set up stripe handler
            this.payment_submitted = false;

            this.handler = StripeCheckout.configure({
                    key: document.getElementById('stripe-public-token').innerHTML,
                    token: function(token) {

                            self.payment_submitted = true;

                            // Update form
                            $( 'input[name="stripeToken"]' ).val(token.id);
                            $( 'input[name="stripeEmail"]' ).val(token.email);

                            //alert($( 'input[name="stripeEmail"]' ).val(token.email));

                            // Submit the form
                            document.getElementById('payment-form').submit();
                    },
                    closed: function () {

                            if (self.payment_submitted == true) {

                                    // Render loading animation to play until payment page refreshes
                                    // TODO: rendering animation should be factored into an object
                                    renderLoadingAnimation();

                                    self.payment_submitted = false;
                            } else {
                                    $('#booking-modal').modal('show');
                                    self.changePageState(null, REVIEW_INFO);
                            }
                    }
            });

            // Close Checkout on page navigation
            $(window).on('popstate', function() {
                this.handler.close();
            });

            // 

        },

        notifyListeners: function (event_type, params) {
            _.each(this.listeners, function (l) {
                l(event_type, params);
            });
        },

        notify: function (event_type, params) {
            if (DATE_UPDATE == event_type) {
                params.controller.notifyListeners(event_type, {
                    controller:       params.controller,
                    schedule_tree:    params.controller.availsCollectionModel.getAvails(),
                    current_date:     params.controller.availsScheduleModel.getCurrentDate(),
                    scheduleRenderer: params.controller.scheduleRenderer
                });
            }
        },

        
        /*
         *  Called when avail block is clicked. When passed as listener, should be wrapped in anon. function 
         *  so 'this' may refer to the controller.
         *  'el' is the element that was clicked, ie. the avail block that was clicked.
         */
        changePageState: function (eventInfo, next_page_state) {
            this.useTracker.submitAction('CHANGE_PAGE_STATE: ' + next_page_state);
            if (TIME_SELECT == next_page_state) {

                // Set the selected booking if opening was clicked
                if (eventInfo != null) {

                    // Selected fields
                    this.selected_owner_id    = parseInt(eventInfo.el.getAttribute("owner_id"));
                    this.selected_venue       = eventInfo.el.getAttribute("venue");
                    this.selected_theatre     = eventInfo.el.getAttribute("theatre");
                    this.selected_date        = eventInfo.el.getAttribute("date");
                    this.selected_start_time  = parseInt(eventInfo.el.getAttribute("start_time"));
                    this.selected_length      = parseInt(eventInfo.el.getAttribute("length")); /* need to get size from selection */
                    this.selected_prime       = parseInt(getFromScheduleTree(this.availsCollectionModel.getAvails(), 'prime', this.selected_venue, this.selected_theatre));
                    this.selected_non_prime   = parseInt(getFromScheduleTree(this.availsCollectionModel.getAvails(), 'non_prime', this.selected_venue, this.selected_theatre));
                    this.selected_insurance   = parseInt(getFromScheduleTree(this.availsCollectionModel.getAvails(), 'insurance', this.selected_venue, this.selected_theatre));
 
                    // Get the relative location of the click
                    var $el = $(eventInfo.el);
                    var x = eventInfo.clickEvent.pageX - $el.offset().left;
                    // Cacluate the ratio: click distance from left / right distance from left
                    var clickPositionRatio = x/$el.width();
                    // Get the actual length from the left side of block to click
                    var clickedLength = (clickPositionRatio*this.selected_length).toFixed();
                    // Get the offset for the slider handles
                    var lower = Math.floor(clickedLength / (30*60))*(30*60);
                    var upper = Math.ceil(clickedLength / (30*60))*(30*60);
                    if (upper < clickedLength || lower > clickedLength) throw "ERROR: Bounds not calculated correctly in VenueController:changePageState";
                    var selectionOffset = Math.abs(upper - clickedLength) < Math.abs(lower - clickedLength) ? upper : lower;
                    // Make sure the selection gives atleast an hour long block of time
                    if (selectionOffset > this.selected_length - (3600)) {
                        selectionOffset = this.selected_length - (3600);
                    }

                    // Default specified values
                    this.specified_start_time = this.selected_start_time + selectionOffset;
                    this.specified_length     = 60*60;
                    this.specified_price      = getBookingPrice(this.selected_date, 
                                                                this.specified_start_time,
                                                                this.specified_length,
                                                                this.selected_prime,
                                                                this.selected_non_prime);

                }

                // Set the page state
                this.page_state = TIME_SELECT;

                // Render the modal content
                var self = this;
                this.scheduleRenderer.renderModal(TIME_SELECT, {selected_venue:       this.selected_venue,
                                                                selected_theatre:     this.selected_theatre,
                                                                selected_date:        this.selected_date,
                                                                selected_start_time:  this.selected_start_time,
                                                                selected_length:      this.selected_length,
                                                                selected_prime:       this.selected_prime,
                                                                selected_non_prime:   this.selected_non_prime,
                                                                selected_insurance:   this.selected_insurance,
                                                                specified_start_time: this.specified_start_time,
                                                                specified_length:     this.specified_length,
                                                                specified_price:      this.specified_price,
                                                                controller:           self,
                                                                clickPositionRatio:   clickPositionRatio
                                                                });

                // Activate the modal
                $('#booking-modal').modal();

            } else if (VENUE_POLICIES == next_page_state) {

                // Set the page state
                this.page_state = VENUE_POLICIES;

                // Get the owner info
                var owner_info = this.availsCollectionModel.getOwnerInfo(this.selected_owner_id);

                // Render the modal content
                this.scheduleRenderer.renderModal(VENUE_POLICIES, owner_info);

            } else if (INPUT_INFO == next_page_state) {

                // Set the page state
                this.page_state = INPUT_INFO;

                // Render the modal content
                var self = this;
                this.scheduleRenderer.renderModal(INPUT_INFO, {controller: self});

            } else if (REVIEW_INFO == next_page_state) {

                if (this.page_state == INPUT_INFO) {

                    // Cacluate the insurance and total cost
                    var accurate_insurance        = (this.selected_insurance * this.specified_length).toFixed(3)/3600;
                    this.specified_insurance_cost = Math.round(accurate_insurance);
                    var accurate_tax              = (this.specified_price + this.specified_insurance_cost).toFixed(3) * TAX_RATE
                    this.specified_tax            = Math.round(accurate_tax);
                    this.specified_total_cost     = Math.round(this.specified_price + this.specified_insurance_cost + accurate_tax);

                }

                // Set the page state
                this.page_state = REVIEW_INFO;

                // Render the modal content
                var self = this;
                this.scheduleRenderer.renderModal(REVIEW_INFO, {selected_venue:           this.selected_venue,
                                                                selected_theatre:         this.selected_theatre,
                                                                selected_date:            this.selected_date,
                                                                selected_start_time:      this.selected_start_time,
                                                                selected_prime:           this.selected_prime,
                                                                selected_non_prime:       this.selected_non_prime,
                                                                selected_insurance:       this.selected_insurance,
                                                                selected_length:          this.selected_length,
                                                                specified_start_time:     this.specified_start_time,
                                                                specified_length:         this.specified_length,
                                                                specified_price:          this.specified_price,
                                                                specified_insurance_cost: this.specified_insurance_cost,
                                                                specified_tax:            this.specified_tax,
                                                                specified_total_cost:     this.specified_total_cost,
                                                                customer_name:            this.customer_name,
                                                                customer_address:         this.customer_address,
                                                                customer_city:            this.customer_city,
                                                                customer_province:        this.customer_province,
                                                                customer_country:         this.customer_country,
                                                                customer_postal:          this.customer_postal,
                                                                customer_phone:           this.customer_phone,
                                                                customer_notes:           this.customer_notes});

            } else if (PAYMENT == next_page_state) {

                // Set the page state
                this.page_state = PAYMENT;


                // Render the modal content
                this.scheduleRenderer.renderModal(PAYMENT, {element:              eventInfo.el,
                                                            handler:              this.handler,
                                                            selected_venue:       this.selected_venue,
                                                            selected_theatre:     this.selected_theatre,
                                                            selected_date:        this.selected_date,
                                                            selected_start_time:  this.selected_start_time,
                                                            selected_length:      this.selected_length,
                                                            specified_start_time: this.specified_start_time,
                                                            specified_length:     this.specified_length,
                                                            specified_price:      this.specified_price,
                                                            specified_tax:        this.specified_tax,
                                                            specified_total_cost: this.specified_total_cost,
                                                            customer_name:        this.customer_name,
                                                            customer_address:     this.customer_address,
                                                            customer_city:        this.customer_city,
                                                            customer_province:    this.customer_province,
                                                            customer_country:     this.customer_country,
                                                            customer_postal:      this.customer_postal,
                                                            customer_phone:       this.customer_phone,
                                                            customer_notes:       this.customer_notes,
                                                            navigation_date:      this.availsScheduleModel.getCurrentDate(),
                                                            navigation_postal:    this.mapModel.getPostal()
                                                         });
            }
 
        },

        /*
         * Callback method to update the specified start_time and length
         */
        updateSpecifiedTimes: function (start_time, length) {
            this.specified_start_time = start_time;
            this.specified_length = length;
            this.useTracker.submitAction('UPDATE_SPECIFIED_TIMES: start: ' + start_time.toString() + " length: " + length.toString());
        },

        /*
         * Change the date of the schedule model by offset
         */
        changeDateByOffset: function (offset) {
            var current_date = parseUTCDate(this.availsScheduleModel.getCurrentDate());
            var new_date = new Date();
            new_date.setUTCDate(1); /* this ensures correct month when setting the month. coded by Ash */
            new_date.setUTCFullYear(current_date.getUTCFullYear());
            new_date.setUTCMonth(current_date.getUTCMonth());
            new_date.setUTCDate(current_date.getUTCDate() + offset);
            this.availsScheduleModel.setCurrentDate(datelessString(new_date));
            this.useTracker.submitAction('CHANGE_DATE_BY_OFFSET: ' + datelessString(new_date));
        },

        /*
         * Change the date of the schedule model by offset
         */
        changeDateByValue: function (date) {
            this.availsScheduleModel.setCurrentDate(date);
            this.useTracker.submitAction('CHANGE_DATE_BY_VALUE: ' + date);
        },

        /*
         * Get more venues for the avails schedule to display
         */
        getMoreVenues: function () {

            var self = this;
            $.get( "api/venues/openings.json", {
                "venue_index": self.availsCollectionModel.avails.venues.length,
                "num_venues": 5,
                "from_date": self.availsScheduleModel.earliest_date,
                "to_date": self.availsScheduleModel.latest_date
            }, function (data) {
                self.availsCollectionModel.addAvails(data);
                self.scheduleRenderer.renderAll(self.availsScheduleModel.getCurrentDate(), self.mapModel.getPostal(), self.availsCollectionModel.getAvails(), self);
            });

        }

    });


    /*
     * Returns an instance of the venue controller
     */
    var loadVenueController = function (availsCollectionModel, availsScheduleModel, mapModel, scheduleRenderer, useTracker) {
        return new VenueController(availsCollectionModel, availsScheduleModel, mapModel, scheduleRenderer, useTracker);
    };

    /*
     * Return an object containing all of our classes and constants
     */
    return {
            VenueController:     VenueController,
            loadVenueController: loadVenueController
    };

};