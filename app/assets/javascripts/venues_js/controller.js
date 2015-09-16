'use strict'

/////////////////////////////////////////////////////////////////////////
// Controller

function createControllerModule () {

  /*
   * Controller states (explanation of each below)
   */
  var SEARCH = 'SEARCH';
  var TIME_SELECT = 'TIME_SELECT';
  var VENUE_POLICIES = 'VENUE_POLICIES';
  var INPUT_INFO = 'INPUT_INFO';
  var REVIEW_INFO = 'REVIEW_INFO';
  var PAYMENT = 'PAYMENT';

  /*
   * Event types
   */
  var DATE_UPDATE = 'DATE_UPDATE';


  /*
   * Controller for the venues page
   */
  var VenueController = function (availsCollectionModel, availsScheduleModel, scheduleRenderer) {
    // Initialize models and renderers
    this.availsCollectionModel = availsCollectionModel;
    this.availsScheduleModel = availsScheduleModel;
    this.scheduleRenderer = scheduleRenderer;

    // Initialize controller listeners
    this.listeners = [];
    this.listeners.push(this.scheduleRenderer.notify);

    // Listen to models
    var self = this;
    this.availsScheduleModel.addListener(self.notify);
  };

  _.extend(VenueController.prototype, {
    /*
     *  Initialize controller
     */
    initializePage: function (schedule_tree) {
      // Controller reference
      var self = this;

      // Set avails in collection model
      this.availsCollectionModel.setAvails(schedule_tree); 

      // Set range and date
      this.availsScheduleModel.setDateRange(this.availsCollectionModel.getAvails());
      this.availsScheduleModel.setCurrentDate('2015-02-10'); // for testing, should initialize actual date

      // Render page
      this.scheduleRenderer.renderAll(this.availsScheduleModel.getCurrentDate(), this.availsCollectionModel.getAvails(), self);

      // Page flow state. Mainly used for modal flow logic.
      // States:
      //   1. SEARCH - Looking through possible availabilities
      //   2. TIME_SELECT - Specifying a start and end of a timeslot
      //   3. VENUE_POLICIES - Reading terms and conditions of booking
      //   4. INPUT_INFO - Filling out customer information fields
      //   5. PAYMENT - Paying for specified booking
      this.page_state = SEARCH;

      // Customer info
      this.customer_name        = '';
      this.customer_phone       = '';
      this.customer_notes       = '';

      // Avail info
      this.selected_venue       = '';
      this.selected_theatre     = '';
      this.selected_prime       = '';
      this.selected_non_prime   = '';
      this.selected_insurance   = '';
      this.selected_date        = '';
      this.selected_start_time  = '';
      this.selected_length      = '';

      // Booking info
      this.specified_start_time = '';
      this.specified_length     = '';
      this.specified_price      = '';
      this.specified_tax        = '';
      this.specified_total_cost = '';

      // Set up stripe handler
      this.payment_submitted = false;
      this.handler = StripeCheckout.configure({
          key: 'pk_test_1Di5chkNtgIMHyHZ6pbKLOrD',
          token: function(token) {
              self.payment_submitted = true;
              // alert("TOKEN - payment_submited: " + self.payment_submitted.toString());
              // Update form
              $( 'input[name="stripeToken"]' ).val(token.id);
              $( 'input[name="stripeEmail"]' ).val(token.email);

              //alert($( 'input[name="stripeEmail"]' ).val(token.email));

              // Submit the form
              document.getElementById('payment-form').submit();
          },
          closed: function () {
              // alert("CLOSED - payment_submitted: " + self.payment_submitted.toString());
              if (self.payment_submitted == true) {
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

    },

    notifyListeners: function (event_type, params) {
      _.each(this.listeners, function (l) {
        l(event_type, params);
      });
    },

    notify: function (event_type, params) {
      if (DATE_UPDATE == event_type) {
        params.controller.notifyListeners(event_type, {controller:       params.controller,
                                                       schedule_tree:    params.controller.availsCollectionModel.getAvails(),
                                                       current_date:     params.controller.availsScheduleModel.getCurrentDate(),
                                                       scheduleRenderer: params.controller.scheduleRenderer});
      }
    },

    
    /*
     *  Called when avail block is clicked. When passed as listener, should be wrapped in anon. function 
     *  so 'this' may refer to the controller.
     *  'el' is the element that was clicked, ie. the avail block that was clicked.
     */
    changePageState: function (el, next_page_state) {
      if (TIME_SELECT == next_page_state) {

        if (el != null) {
          // Set the selected booking
          this.selected_venue = el.getAttribute("venue");
          this.selected_theatre = el.getAttribute("theatre");
          this.selected_date = el.getAttribute("date");
          this.selected_start_time = el.getAttribute("start_time");
          this.selected_length = el.getAttribute("length"); /* need to get size from selection */
          this.selected_prime = getFromScheduleTree(this.availsCollectionModel.getAvails(), 'prime', this.selected_venue, this.selected_theatre);
          this.selected_non_prime = getFromScheduleTree(this.availsCollectionModel.getAvails(), 'non_prime', this.selected_venue, this.selected_theatre);
          this.selected_insurance = getFromScheduleTree(this.availsCollectionModel.getAvails(), 'insurance', this.selected_venue, this.selected_theatre);
        }

        // Set the page state
        this.page_state = TIME_SELECT;

        // Render the modal content
        var self = this;
        this.scheduleRenderer.renderModal(TIME_SELECT, {selected_venue:      this.selected_venue,
                                                        selected_theatre:    this.selected_theatre,
                                                        selected_date:       this.selected_date,
                                                        selected_start_time: this.selected_start_time,
                                                        selected_length:     this.selected_length,
                                                        selected_prime:      this.selected_prime,
                                                        selected_non_prime:  this.selected_non_prime,
                                                        selected_insurance:  this.selected_insurance,
                                                        controller:          self
                                                        });

        // Activate the modal
        $('#booking-modal').modal();

      } else if (VENUE_POLICIES == next_page_state) {

        // Set the page state
        this.page_state = VENUE_POLICIES;

        // Render the modal content
        this.scheduleRenderer.renderModal(VENUE_POLICIES);

      } else if (INPUT_INFO == next_page_state) {

        // Set the page state
        this.page_state = INPUT_INFO;

        // Render the modal content
        this.scheduleRenderer.renderModal(INPUT_INFO, null);

      } else if (REVIEW_INFO == next_page_state) {

        if (this.page_state == INPUT_INFO) {

          this.specified_price      = Math.round(this.selected_prime * getHoursFromSeconds(this.specified_length));
          this.specified_tax        = Math.round((this.specified_price + this.selected_insurance) * TAX_RATE);
          this.specified_total_cost = Math.round(this.specified_price + this.selected_insurance + this.specified_tax);

        }

        // Set the page state
        this.page_state = REVIEW_INFO;

        // Render the modal content
        var self = this;
        this.scheduleRenderer.renderModal(REVIEW_INFO, {selected_venue:       this.selected_venue,
                                                        selected_theatre:     this.selected_theatre,
                                                        selected_date:        this.selected_date,
                                                        selected_start_time:  this.selected_start_time,
                                                        selected_prime:       this.selected_prime,
                                                        selected_non_prime:   this.selected_non_prime,
                                                        selected_insurance:   this.selected_insurance,
                                                        selected_length:      this.selected_length,
                                                        specified_start_time: this.specified_start_time,
                                                        specified_length:     this.specified_length,
                                                        specified_price:      this.specified_price,
                                                        specified_tax:        this.specified_tax,
                                                        specified_total_cost: this.specified_total_cost,
                                                        customer_name:        this.customer_name,
                                                        customer_phone:       this.customer_phone,
                                                        customer_notes:       this.customer_notes});

      } else if (PAYMENT == next_page_state) {

        // Set the page state
        this.page_state = PAYMENT;


        // Render the modal content
        this.scheduleRenderer.renderModal(PAYMENT, {element:              el,
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
                                                    customer_phone:       this.customer_phone,
                                                    customer_notes:       this.customer_notes,
                                                    navigation_date:      this.availsScheduleModel.getCurrentDate()
                                                   });
      }
 
    },

    /*
     * Callback method to update the specified start_time and length
     */
    updateSpecifiedTimes: function (start_time, length) {
      this.specified_start_time = start_time;
      this.specified_length = length;
    },

    /*
     * Change the date of the schedule model by offset
     */
    changeDateByOffset: function (offset) {
      var current_date = parseUTCDate(this.availsScheduleModel.getCurrentDate());
      var new_date = new Date();
      new_date.setUTCFullYear(current_date.getUTCFullYear());
      new_date.setUTCMonth(current_date.getUTCMonth());
      new_date.setUTCDate(current_date.getUTCDate() + offset);
      this.availsScheduleModel.setCurrentDate(datelessString(new_date));
    },

    /*
     * Change the date of the schedule model by offset
     */
    changeDateByValue: function (date) {
      console.log("Changing date to: " + date);
      this.availsScheduleModel.setCurrentDate(date);
    }

  });


  /*
   * Returns an instance of the venue controller
   */
  var loadVenueController = function (availsCollectionModel, availsScheduleModel, scheduleRenderer) {
    return new VenueController(availsCollectionModel, availsScheduleModel, scheduleRenderer);
  };

  /*
   * Return an object containing all of our classes and constants
   */
  return {
      VenueController: VenueController,
      loadVenueController: loadVenueController
  };

};