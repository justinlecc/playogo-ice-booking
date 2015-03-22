'use strict'
//////////////////////////////////////////////////////////////
// Helpers 

var MONTH_NAMES = ["January", "February", "March", "April", "May", "June", 
                   "July", "August", "September", "October", "November", "December"];

var NAME_COL_WIDTH_PCT = 33;

// Returns monday of current day d (http://stackoverflow.com/questions/4156434/javascript-get-the-first-day-of-the-week-from-current-date)
function getMonday(d) {
  d = new Date(d);
  var day = d.getDay(),
      diff = d.getDate() - day + (day == 0 ? -6:1); // adjust when day is sunday
  return new Date(d.setDate(diff));
}

// Pads integer with 0 if less than 10
function toPaddedString(num) {
  if (num < 10) {
    return '0' + parseInt(num);
  } else {
    return parseInt(num);
  }
}

// Returns the height of an element even when not rendered in the dom
function getHeight(element)
{
    element.style.visibility = "hidden";
    document.body.appendChild(element);
    var height = element.offsetHeight + 0;
    document.body.removeChild(element);
    element.style.visibility = "visible";
    return height;
}

// Returns a string representing a time of day.
function getTimeFromSeconds(seconds) {
  var d = new Date(Date.UTC(2015, 0, 1, 0, 0, seconds));
  var hour = d.getUTCHours();
  var minute = d.getUTCMinutes();
  var morning;
  var time = '';

  // Morning hour
  if (hour < 12) {
    morning = true;
    if (hour == 0) {
      time += '12'
    } else if (hour < 10) {
      time += '0' + hour.toString();
    } else {
      time += hour.toString();
    }
  // Afternoon hour
  } else {
    morning = false;
    if (hour == 12) {
      time += '12';
    } else {
      time += parseInt(hour - 12);
    }
  }

  time += ':';

  // Minute
  if (minute < 10) {
    time += '0' + minute;
  } else {
    time += minute;
  }

  // am/pm
  if (morning) {
    time += 'am';
  } else {
    time += 'pm';
  }

  return time;
}

// Return the price given start time, end time, prime price and non prime price
function getPrice (start_time, end_time, prime, non_prime) {
  return prime;
}

/////////////////////////////////////////////////////////////////
// View

  /*
   * Controller states (explanation of each below)
   */
  var SEARCH = 'SEARCH';
  var TIME_SELECT = 'TIME_SELECT';
  var VENUE_POLICIES = 'VENUE_POLICIES';
  var INPUT_INFO = 'INPUT_INFO';
  var REVIEW_INFO = 'REVIEW_INFO';
  var PAYMENT = 'PAYMENT';

function createViewModule () {

  /*
   * ScheduleRenderer
   *     Handles rendering the avails schedule
   *
  */ 
  var ScheduleRenderer = function () {

  };

  _.extend(ScheduleRenderer.prototype,{
    

    /*
     * Renders the month nav
     */ 
    renderMonthNav: function (current_date) {
      var container = document.getElementById('month-nav-container');
      var template = document.getElementById('avails-month-template');
      var content = document.createElement('div');
      content.innerHTML = template.innerHTML;

      // Month button
      content.children[0].children[0].innerHTML = MONTH_NAMES[parseDate(current_date).getMonth()];

      // Week button *Need to update dropdown*
      var monday = getMonday(parseDate(current_date)).getDate();
      content.children[0].children[1].innerHTML = monday.toString() + " - " + (monday+6).toString();


      container.appendChild(content);
    },

    /*
     * Renders the day nav
     */ 
    renderDayNav: function (current_date) {
      var container = document.getElementById('day-nav-container');
      var template = document.getElementById('avails-days-template');
      var content = document.createElement('div');
      content.innerHTML = template.innerHTML;
      var tabs = content.children[0].children;

      // Back and forward tab

      // Day tabs
      var start_week = getMonday(parseDate(current_date));

      for (var i=1; i < tabs.length - 1; i++) {
        tabs[i].children[0].innerHTML = start_week.getDate();
        if (start_week.getDate() == parseDate(current_date).getDate()) {
          tabs[i].classList.add('active');
        }
        start_week.setDate(start_week.getDate() + 1);
      }
      
      container.appendChild(content);
    },

    /*
     * Renders the hours row
     */ 
    renderHoursRow: function () {
      /* Hard coded variables */
      var start = 6;
      var end = 24;
      var NAME_COL_WIDTH_PCT = 33;

      // Dom elements to be used
      var container = document.getElementById('hours-row-container');
      var template = document.getElementById('avails-hours-template');
      var element;

      // Name column
      element = document.createElement('div');
      element.className = 'name-col';
      element.style.width = NAME_COL_WIDTH_PCT.toString() + '%';
      container.appendChild(element);


      element = document.createElement('div');
      element.className = 'hour-col';
      element.style.width =  (100-NAME_COL_WIDTH_PCT).toString() + '%';
      container.appendChild(element);

      // Hour columns
      // var time = new Date();
      // time.setHours(start);
      // for (var i=start; i<end - 1; i++) {
      //   var h = time.getHours();
      //   // var postfix = '';
      //   // if (h % 2 == start % 2) {
      //   //   postfix = ((h >= 12)? 'pm' : 'am');
      //   // }
      //   //   hours[i].innerHTML = ((h + 11) % 12 + 1).toString() + postfix;
      //   // if (i % 2 == 1) {
      //   //   hours[i].classList.add('odd');
      //   // }
      //   element = document.createElement('div');
      //   element.className = 'hour-col';
      //   element.style.width =  (((name_col_width_px*2) / (end-start)) + .5).toString() + 'px';
      //   container.appendChild(element);
      //   time.setHours(time.getHours()+1);
      // }

      // Clearfix
      element = document.createElement('div');
      element.className = 'clearfix'
      container.appendChild(element);
    },

    /*
     * Renders the venue rows
     */  
    renderVenueRows: function (schedule_tree, current_date) {
      // Relevent data
      var earliest_open = 6*60*60; // 6 hours
      var latest_close = 25*60*60; // 25 hours
      var time = latest_close - earliest_open;

      var container = document.getElementById('venue-rows-container');

      var venues = schedule_tree.venues;
      _.each(venues, function (venue) {
        // Venue
        var venue_row = document.createElement('div');
        venue_row.className = 'venue-row';
        venue_row.innerHTML = venue.name;
        container.appendChild(venue_row);

        _.each(venue.theatres, function (theatre) {
          // Theatre
          var theatre_row = document.createElement('div');
          venue_row.className = 'theatre-row row';
          venue_row.appendChild(theatre_row);

          // Same height cols
          var same_height = document.createElement('div');
          same_height.className = 'row-same-height';
          theatre_row.appendChild(same_height);

          // Theatre name
          var name_col = document.createElement('div');
          name_col.className = 'name-col col-xs-3 col-same-height'
          name_col.innerHTML = theatre.name;
          same_height.appendChild(name_col);

          // Theatre avails
          var sched_col = document.createElement('div');
          sched_col.className = 'sched-col col-xs-9 col-same-height';
          same_height.appendChild(sched_col);

          // Days
          for (var i=0; i < theatre.days.length; i++) {
            var day = theatre.days[i];

            if (day.date == current_date) {
              // Render avails
              _.each(day.blocks, function (avail) {
                // Avails
                var length = avail.length;
                var start_time = avail.start;

                // Get the display area width
                var space = sched_col.offsetWidth;

                // Get the margin and width in px
                var time_before_avail = start_time - earliest_open;
                var space_before_avail = (time_before_avail * space) / time; // margin
                var space_of_avail = (length * space) / time; // width

                // Get top offset
                var parent_height = sched_col.offsetHeight;
                var top_offset = (parent_height / 2) - (12 /* avail height 12px */ / 2);

                // Place the avail
                var avail_block = document.createElement('div');
                avail_block.className = 'avail-block';
                avail_block.style.left = space_before_avail.toString() + 'px';
                avail_block.style.top = top_offset.toString() + 'px';
                avail_block.style.width = space_of_avail.toString() + 'px';

                // Set the values of avail
                avail_block.setAttribute('venue', venue.name);
                avail_block.setAttribute('theatre', theatre.name);
                avail_block.setAttribute('date', day.date);
                avail_block.setAttribute('start_time', avail.start);
                avail_block.setAttribute('length', avail.length);

                // Append
                sched_col.appendChild(avail_block);
              });

              break;
            }
          }
        });
      });
    },


    /*
     * Renders the popover
     */ 
    renderModal: function (state, info) {
      // Hide all modal buttons (correct button will be displayed by case)
      var modal_btns = document.getElementById('booking-modal-btns').children; //.children();
        _.each(modal_btns, function (el) {
          el.style.display = 'none';
        });

      // State dependent control flow
      if (state == TIME_SELECT) {

        // Modal title
        var modal_title = document.getElementById('booking-modal-title');
        modal_title.innerHTML = 'Please select a start and end time.';

        // Modal body
        var modal_body = document.getElementById('booking-modal-body');
        var modal_body_template = document.getElementById('modal-body-timeselect-template');
        modal_body.innerHTML = modal_body_template.innerHTML;

        // Modal slider range
        var earliest_start = parseInt(info.selected_start_time);
        var latest_end = parseInt(info.selected_start_time) + parseInt(info.selected_length);

        if (((latest_end - earliest_start) % (30 * 60)) != 0) {
          throw "ERROR: timeslot range is not a multiple of half hours. It's " + (latest_end - earliest_start).toString(); 
        };

        // Get time selection options
        var time_options = [];
        var cur_time = earliest_start;
        while (cur_time <= latest_end) {
          time_options.push(cur_time);
          cur_time += 30 * 60;
        }

        // Get time selection options in string form
        var time_options_str = [];
        _.each(time_options, function (option) {
          time_options_str.push(getTimeFromSeconds(option));
        });

        // Initialize the slider
        $(".timeselect-slider").slider({
          range: true,
          min: 0,
          max: time_options.length - 1,
          values: [ 0, 2 ],
          // What to do on change
          slide: function( event, ui ) {
            var start_time = time_options[ ui.values[ 0 ] ];
            var end_time = time_options[ ui.values[ 1 ] ];
            var price_per_hour = getPrice(start_time, end_time, info.selected_prime, info.selected_non_prime) / 100;
            $( "#modal-selected-timerange" ).html( getTimeFromSeconds(time_options[ ui.values[ 0 ] ]) + " to " + getTimeFromSeconds(time_options[ ui.values[ 1 ] ]));
            $( "#modal-selected-price" ).html( '$' +  (price_per_hour * ((time_options[ ui.values[1] ] - time_options[ ui.values[0] ])/(60*60))));
          }
        })

        // Add pips with the labels set to "months"
        .slider("pips", {
          rest: "label",
          labels: time_options_str
        });

        // Initial ice time range
        $( "#modal-selected-timerange" ).html( getTimeFromSeconds(time_options[0]) +
        " to " + getTimeFromSeconds(time_options[1]) );

        // Initial ice time price
        var start_time = time_options[ 0 ];
        var end_time = time_options[ 2 ];
        var price_per_hour = getPrice(start_time, end_time, info.selected_prime, info.selected_non_prime) / 100; 
        $( "#modal-selected-price" ).html( '$' +  ( price_per_hour * ( (time_options[2] - time_options[0]) / (60*60) ) ).toString() 
                                          + " (@ $" + price_per_hour + "/h)");
        // Set venue
        $( "#modal-selected-venue").html(info.selected_venue + " - " + info.selected_theatre);

        // Modal button
        var modal_btn = document.getElementById('booking-modal-btn-timeselect');
        modal_btn.style.display = 'inline';

      } else if (state == VENUE_POLICIES) {

        // Modal title
        var modal_title = document.getElementById('booking-modal-title');
        modal_title.innerHTML = 'Booking an ice time with Kitchener.';

        // Modal body
        var modal_body = document.getElementById('booking-modal-body');
        modal_body.innerHTML = 'VENUE_POLICIES modal body content.';

        // Modal button
        var modal_btn = document.getElementById('booking-modal-btn-venuepolicies');
        modal_btn.style.display = 'inline';

      } else if (state == INPUT_INFO) {

        // Modal title
        var modal_title = document.getElementById('booking-modal-title');
        modal_title.innerHTML = 'Please fill in the following information.';

        // Modal body
        var modal_body = document.getElementById('booking-modal-body');
        var modal_body_template = document.getElementById('modal-body-inputinfo-template');
        modal_body.innerHTML = modal_body_template.innerHTML;

        // Modal button
        var modal_btn = document.getElementById('booking-modal-btn-inputinfo');
        modal_btn.style.display = 'inline';

      } else if (state == REVIEW_INFO) {

        // Modal title
        var modal_title = document.getElementById('booking-modal-title');
        modal_title.innerHTML = 'Please confirm your booking details.';

        // Modal body
        var modal_body = document.getElementById('booking-modal-body');
        var modal_body_template = document.getElementById('modal-body-reviewinfo-template');
        modal_body.innerHTML = modal_body_template.innerHTML;


        modal_body.children[0].innerHTML = info.selected_venue + " - " + info.selected_theatre;
        modal_body.children[1].innerHTML = info.selected_date + " - " + info.selected_start_time + " - " + (info.selected_start_time + info.selected_length);
        modal_body.children[2].innerHTML = "**total price**";
        modal_body.children[3].innerHTML = info.customer_name;
        modal_body.children[4].innerHTML = info.customer_phone;
        modal_body.children[5].innerHTML = info.customer_notes;


        // Modal button
        var modal_btn = document.getElementById('booking-modal-btn-reviewinfo');
        modal_btn.style.display = 'inline';


      } else if (state == PAYMENT) {

        var payment_form = document.getElementById('payment-form');
        var inputs = payment_form.children;

        // Fills in the following inputs
        /*
        <input type="hidden" name="stripeToken" value="">
        <input type="hidden" name="stripeEmail" value="">
        <input type="hidden" name="venue" value="">
        <input type="hidden" name="theatre" value="">
        <input type="hidden" name="date" value="">
        <input type="hidden" name="start_time" value="">
        <input type="hidden" name="length" value="">
        <input type="hidden" name="amount" value="">
        <input type="hidden" name="nav_date" value="">
        <input type="hidden" name="name" value="">
        <input type="hidden" name="phone" value="">
        <input type="hidden" name="notes" value="">
        */

        // Stripe token and email filled out on payment

        // Venue
        inputs[2].value = info.selected_venue;
        // Theatre
        inputs[3].value = info.selected_theatre;
        // Date
        inputs[4].value = info.selected_date;
        // Start time
        inputs[5].value = info.selected_start_time;
        // Length
        inputs[6].value = info.selected_length;
        // Amount
        inputs[7].value = 20000;
        // Nav date
        inputs[8].value = info.navigation_date;
        // Name
        inputs[9].value = info.customer_name;
        // Phone
        inputs[10].value = info.customer_name;
        // Notes
        inputs[11].value = info.customer_notes;


        // Close the modal
        $('#booking-modal').modal('hide');


      }
    },

    /*
     * Renders the entire schedule
     */ 
     renderAll: function (current_date, schedule_tree) {
      this.renderMonthNav(current_date);
      this.renderDayNav(current_date);
      //this.renderHoursRow();
      this.renderVenueRows(schedule_tree, current_date);
     }

  });

  // /*
  //  * Creates a Schedule Renderer
  //  */ 
  function loadScheduleRenderer () {
    return new ScheduleRenderer();
  };


  // Return an object containing all of our classes and constants
  return {
      ScheduleRenderer: ScheduleRenderer,
      loadScheduleRenderer: loadScheduleRenderer
  };
}