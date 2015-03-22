'use strict'

/////////////////////////////////////////////////////////////////////////
// Helpers

// Get a dateless string from date object
var datelessString = function (date) {
  var year = date.getFullYear();
  year = year.toString();
  var month = date.getMonth();
  if (month < 10) {
      month = '0' + month.toString();
  } else {
      month = month.toString();
  }
  var day = date.getDate();
  if (day < 10) {
      day = '0' + day.toString();
  } else {
      day = day.toString();
  }

  return year + "-" + month + "-" + day;
};

// parse a date in yyyy-mm-dd format
function parseDate(input) {
  var parts = input.split('-');
  // new Date(year, month [, day [, hours[, minutes[, seconds[, ms]]]]])
  return new Date(parts[0], parts[1]-1, parts[2]); // Note: months are 0-based
}

// retrieves info from the schedule_tree
function getFromScheduleTree(schedule_tree, item, venue, theatre) {
  var return_value = false;

  if ('prime' == item) {
    _.each(schedule_tree.venues, function (iter_venue) {
      if (venue == iter_venue.name) {
        _.each(iter_venue.theatres, function (iter_theatre) {
          if (theatre == iter_theatre.name) {
            return_value = iter_theatre.prime;
          }
        })
      }
    })

    if (!return_value) {
      throw 'ERROR: did not find matching venue and theatre';
    }
  } else if ('non_prime' == item) {
    _.each(schedule_tree.venues, function (iter_venue) {
      if (venue == iter_venue.name) {
        _.each(iter_venue.theatres, function (iter_theatre) {
          if (theatre == iter_theatre.name) {
            return_value = iter_theatre.non_prime;
          }
        })
      }
    })

    if (!return_value) {
      throw 'ERROR: did not find matching venue and theatre';
    }
  }
  return return_value;
};


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
   * Controller for the venues page
   */
  var VenueController = function (availsCollectionModel, availsScheduleModel, scheduleRenderer) {
    // Initialize models and renderers
    this.availsCollectionModel = availsCollectionModel;
    this.availsScheduleModel = availsScheduleModel;
    this.scheduleRenderer = scheduleRenderer;
  };

  _.extend(VenueController.prototype, {
    /*
     *  Initialize controller
     */
    initializePage: function (schedule_tree) {
      // Set avails in collection model
      this.availsCollectionModel.setAvails(schedule_tree); 

      // Set date range
      this.availsScheduleModel.setDateRange(this.availsCollectionModel.getAvails());

      // Set date
      this.scheduleRenderer.renderAll('2015-02-10'/* TO DO: this.availsScheduleModel.getCurrentDate() */, this.availsCollectionModel.getAvails());

      // Page flow state. Mainly used for modal flow logic.
      // States:
      //   1. SEARCH - Looking through possible availabilities
      //   2. TIME_SELECT - Specifying a start and end of a timeslot
      //   3. VENUE_POLICIES - Reading terms and conditions of booking
      //   4. INPUT_INFO - Filling out customer information fields
      //   5. PAYMENT - Paying for specified booking
      this.page_state = SEARCH;

      // Customer info
      this.customer_name = '';
      this.customer_phone = '';
      this.customer_notes = '';

      // Avail info
      this.selected_venue = '';
      this.selected_theatre = '';
      this.selected_prime = '';
      this.selected_non_prime = '';
      this.selected_date = '';
      this.selected_start_time = '';
      this.selected_length = '';

      // Booking info
      this.specified_start_time = '';
      this.specified_length = '';

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
        }

        // Set the page state
        this.page_state = TIME_SELECT;

        // Render the modal content
        this.scheduleRenderer.renderModal(TIME_SELECT, {selected_venue: this.selected_venue,
                                                        selected_theatre: this.selected_theatre,
                                                        selected_date: this.selected_date,
                                                        selected_start_time: this.selected_start_time,
                                                        selected_length: this.selected_length,
                                                        selected_prime: this.selected_prime,
                                                        selected_non_prime: this.selected_non_prime});

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

        // Set the page state
        this.page_state = REVIEW_INFO;

        // Render the modal content
        this.scheduleRenderer.renderModal(REVIEW_INFO, {selected_venue: this.selected_venue,
                                                        selected_theatre: this.selected_theatre,
                                                        selected_date: this.selected_date,
                                                        selected_start_time: this.selected_start_time,
                                                        selected_length: this.selected_length,
                                                        customer_name: this.customer_name,
                                                        customer_phone: this.customer_phone,
                                                        customer_notes: this.customer_notes});

      } else if (PAYMENT == next_page_state) {

        // Set the page state
        this.page_state = PAYMENT;


        // Render the modal content
        this.scheduleRenderer.renderModal(PAYMENT, {selected_venue: this.selected_venue,
                                                    selected_theatre: this.selected_theatre,
                                                    selected_date: this.selected_date,
                                                    selected_start_time: this.selected_start_time,
                                                    selected_length: this.selected_length,
                                                    customer_name: this.customer_name,
                                                    customer_phone: this.customer_phone,
                                                    customer_notes: this.customer_notes,
                                                    navigation_date: this.availsScheduleModel.getCurrentDate()});
      }
 
    }

    /*
     *  Called when continue clicked on TIME_SELECT state modal or back on INPUT_INFO
     */


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