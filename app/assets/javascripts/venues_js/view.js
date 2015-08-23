'use strict'



//////////////////////////////////////////////////////////////
// Globals

/*
 * The percentage of the schedule grid that the name column takes up
 */
var NAME_COL_WIDTH_PCT = 33;

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

/////////////////////////////////////////////////////////////////
// View

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
     * Renders the date picker
     */ 
    renderDatePicker: function (current_date, controller){

      // var datePickerInput = $("#datepicker");

      // datePickerInput.datepicker();
      // datePickerInput.datepicker("option", "dateFormat", "yy-mm-dd");

      // datePickerInput.val(current_date);

      // // Define event listener
      // datePickerInput.change(function () {
      //   controller.changeDateByValue(this.value);
      // });

    },

    /*
     * Renders the month nav
     */ 
    renderMonthNav: function (current_date, controller) {
      var container = document.getElementById('month-nav-container');
      var template = document.getElementById('avails-month-template');

      // Put template into container
      container.innerHTML = template.innerHTML;

      // Get month button
      var month_button = container.children[1];

      // Add month to month button
      month_button.innerHTML = MONTH_NAMES[parseUTCDate(current_date).getUTCMonth()];

      // Add icon to month button
      var calendar_icon = document.createElement('span');
      calendar_icon.className = 'glyphicon glyphicon-calendar calendar-icon';
      month_button.appendChild(calendar_icon);

      // Add datepicker
      $(month_button).click(function () {
        var datepicker = $(document.getElementById("datepicker"));

        if (datepicker.attr("state") === "closed") {
          console.log("in closed case");
          datepicker.datepicker({
            dateFormat: "yy-mm-dd",
            beforeShow: function(input, obj) {
              var widget = $(input).datepicker('widget');
              $(input).after(widget);
              widget.css("top", "0px");
              widget.css("left", "0px");
            },
            onClose: function(dateText, inst) {
              console.log("onClose");
              this.setAttribute("state", "closed");
            }
          });

          datepicker.datepicker("setDate", current_date);

          // Datepicker change event
          datepicker.change(function () {
            controller.changeDateByValue(this.value);
          });

          datepicker.datepicker("show");
          var widget = datepicker.datepicker('widget');
          widget.css("top", "24px");
          widget.css("left", "0px");
          datepicker.attr("state", "open");
          console.log("should be open")

        } else if (datepicker.attr("state") === "open") {
          console.log("in open case");
          datepicker.datepicker("hide");

        } else {
          throw "ERROR: Unidentified state in datepicker input";
        }
      });

    },

    /*
     * Renders the day nav
     */ 
    renderDayNav: function (current_date, controller) {
      var container = document.getElementById('day-nav-container');
      var content = container;
      var template = document.getElementById('day-nav-template');
      content.innerHTML = template.innerHTML;

      var tabs = content.children[0].children;

      // Set the current day of the month
      var current_utc_date = parseUTCDate(current_date);

      // Day tabs
      var start_of_week = getMonday(current_utc_date);

      // Days of the week
      var days_of_week = [];

      // Define event listener
      var clickDayNav = function () {
        var date = parseUTCDate(this.getAttribute('day').toString());
        var current_day = current_utc_date;
        // console.log("Date getTime: " + (date.getTime()-1));
        // console.log("Cur day getTime: " + (current_day.getTime()-1));
        var time_diff = date.getTime() - current_day.getTime();
        if (time_diff % (1000 * 3600 * 24) != 0) {
          throw "ERROR: difference in time was not a mod a full day."
        }
        var nav_value = time_diff / (1000 * 3600 * 24);
        if (nav_value == 0) {
          // do nothing
        } else {
          controller.changeDateByOffset(nav_value);
        }
      };

      // Copy start of week date object for iteration
      var iter_day = new Date(start_of_week.getTime());

      // Days of the week: Monday through Sunday
      for (var i=1; i < tabs.length - 1; i++) {

        // Render the day tabs
        if (iter_day.getUTCDate() < start_of_week.getUTCDate()) {
          tabs[i].children[0].innerHTML = DAYS_OF_WEEK[(iter_day.getUTCDate()+start_of_week.monthDays()) - start_of_week.getUTCDate()];
        } else {
          tabs[i].children[0].innerHTML = DAYS_OF_WEEK[iter_day.getUTCDate() - start_of_week.getUTCDate()];
        }

        tabs[i].children[1].innerHTML = iter_day.getUTCDate();

        if (iter_day.getUTCDate() == current_utc_date.getUTCDate()) {
          addClass(tabs[i],'active');
        } else {
          removeClass(tabs[i], 'active');
        };

        // Store date being represented
        tabs[i].setAttribute('day', datelessString(iter_day));

        // Add event listener
        tabs[i].addEventListener('click', clickDayNav);

        iter_day.setUTCDate(iter_day.getUTCDate() + 1);
      }

      // Week back button
      tabs[0].setAttribute('day', datelessString(new Date(Date.UTC(current_utc_date.getUTCFullYear(), current_utc_date.getUTCMonth(), current_utc_date.getUTCDate()) - (1 * 86400000 /* one day in milliseconds */)))); // a day back
      tabs[0].addEventListener('click', clickDayNav);
      // Week forward button
      tabs[8].setAttribute('day', datelessString(new Date(Date.UTC(current_utc_date.getUTCFullYear(), current_utc_date.getUTCMonth(), current_utc_date.getUTCDate()) + (1 * 86400000 /* one day in milliseconds */)))); // a day back
      tabs[8].addEventListener('click', clickDayNav);
      
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

      // Clearfix
      element = document.createElement('div');
      element.className = 'clearfix'
      container.appendChild(element);
    },

    /*
     * Renders the venue rows
     */  
    renderVenueRows: function (schedule_tree, current_date, controller) {
      // Resolve when venue rows have been created
      var deferred = $.Deferred();

      // Relevent data
      var earliest_open = 6*60*60; // 6 hours
      var latest_close = 25*60*60; // 25 hours (1am tomorrow)
      var time = latest_close - earliest_open;
      var color_iter = Math.round( Math.random() * 10 ); // can start randomly

      // Get container
      var container = document.getElementById('venue-rows-container');
      container.innerHTML = '';

      // Iterate for each venue in schedule_tree
      var venues = schedule_tree.venues;
      _.each(venues, function (venue) {

        /* Make venue container */
        var venue_row = document.createElement('div');
        venue_row.className = 'venue-row row';
        container.appendChild(venue_row);


        /* Venue name row */
        var venue_name_row = document.createElement('div');
        venue_name_row.className = 'venue-name-row';
        venue_row.appendChild(venue_name_row);

        // Same height cols
        var same_height = document.createElement('div');
        same_height.className = 'row-same-height';
        venue_name_row.appendChild(same_height);

        // Name column
        var venue_name_col = document.createElement('div');
        venue_name_col.className = 'venue-name-col col-xs-12 col-same-height';
        venue_name_col.innerHTML = venue.name + " (" + venue.duration.text + ")";
        same_height.appendChild(venue_name_col);

        // Extra space (for future venue attributes; not currently used)
        // var venue_extras_col = document.createElement('div');
        // venue_extras_col.className = 'venue-extras-col col-xs-9 col-same-height';
        // same_height.appendChild(venue_extras_col);

        /* Make hours row */
        // set element details
        var hours_row_template = document.getElementById('avails-hours-template');
        var hours_row = document.createElement('div');
        hours_row.className = 'hours-row';
        hours_row.innerHTML = hours_row_template.innerHTML;
        venue_row.appendChild(hours_row);


        // prepare for printing hours
        var cur_time = earliest_open;
        var num_hours = (latest_close - earliest_open) / (60*60);
        var i = 0;
        var hours_col = hours_row.children[0].children[1];
        var space = hours_col.offsetWidth; // width of hours col

        // print hours
        while (cur_time <= latest_close) {

          // create hour element
          var hour = document.createElement('div');
          if (i % 2) {
            hour.className = 'hour odd';
          } else {
            hour.className = 'hour';
          }
          hour.style.left = (space / num_hours)*i + 'px';
          hour.style.top = '4px'; 

          // make hour (12 hour clock)
          var hour_str = getTwelveHour(cur_time);

          hour.innerHTML = hour_str;

          hours_col.appendChild(hour);

          cur_time += 60*60; // 1 hour
          i++;
        }

        // Make theatres
        _.each(venue.theatres, function (theatre) {

          var theatre_row = document.createElement('div');
          theatre_row.className = 'theatre-row';
          venue_row.appendChild(theatre_row);

          // Same height cols
          var same_height = document.createElement('div');
          same_height.className = 'row-same-height';
          theatre_row.appendChild(same_height);

          // Theatre name
          var name_col = document.createElement('div');
          name_col.className = 'name-col col-xs-3 col-same-height';
          name_col.innerHTML = theatre.name;
          same_height.appendChild(name_col);

          // Theatre avails
          var sched_col = document.createElement('div');
          sched_col.className = 'sched-col col-xs-9 col-same-height';
          same_height.appendChild(sched_col);

          // Section divides
          var cur_time = earliest_open;
          var num_hours = (latest_close - earliest_open) / (60*60);
          var i = 0;
          var space = hours_col.offsetWidth; // width of hours col
          while (cur_time < latest_close) {
            var divider = document.createElement('div');
            divider.className = 'divider';
            divider.style.left = (space / num_hours)*i + 'px';
            sched_col.appendChild(divider);
            cur_time += 60*60;
            i++;
          }

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

                // Set event listener
                avail_block.addEventListener('click', function () {
                  controller.changePageState(this, TIME_SELECT);
                });

                // Append
                sched_col.appendChild(avail_block);
              });

              break;
            }
          }
        });
        color_iter++;
      });

      // Resolve that the venue rows have been created
      deferred.resolve();
      return deferred;
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
        modal_title.innerHTML = 'Select a start and end time.';

        // Modal body
        var modal_body = document.getElementById('booking-modal-body');
        var modal_body_template = document.getElementById('modal-body-timeselect-template');
        modal_body.innerHTML = modal_body_template.innerHTML;

        // Modal slider range
        var earliest_start = parseInt(info.selected_start_time);
        var latest_end = parseInt(info.selected_start_time) + parseInt(info.selected_length);

        if (((latest_end - earliest_start) % (30 * 60)) != 0) {
          throw "ERROR: timeslot range is not a multiple of half hours. It's " + (latest_end - earliest_start).toString(); 
        }

        // Get time selection options
        var time_options = [];
        var cur_time = earliest_start;
        while (cur_time <= latest_end) {
          time_options.push(cur_time);
          cur_time += 30 * 60;
        }

        // Initialize the slider
        var slider = $(".timeselect-slider");
        slider.append('<div class="ui-slider-handle"><div id="start-tooltip" data-tooltip="Start" class="range-handle"></div></div>');
        slider.append('<div class="ui-slider-handle"><div id="end-tooltip" data-tooltip="Finish" class="range-handle"></div></div>');

        slider.slider({
          range: true,
          min: 0,
          max: time_options.length - 1,
          values: [ 0, 2 ],
          valueStore: 'test',
          // What to do on change
          slide: function (event, ui) {
            var self  = $(this)
            var max = self.slider('option', 'max');
            var min = self.slider('option', 'min');

            if (ui.values[0] + 1 >= ui.values[1] || ui.values[0] < min || ui.values[1] > max) {
              return false;
            } 

            var start_time = time_options[ ui.values[ 0 ] ];
            var end_time = time_options[ ui.values[ 1 ] ];

            // Update time range in visible span and controller
            var timerange_element = $( "#modal-selected-timerange" )
            timerange_element.html( getTimeFromSeconds(time_options[ ui.values[ 0 ] ]) + " to " + getTimeFromSeconds(time_options[ ui.values[ 1 ] ]));
            info.controller.specified_start_time = time_options[ ui.values[ 0 ] ];
            info.controller.specified_length = time_options[ ui.values[ 1 ] ] - time_options[ ui.values[ 0 ] ];

            // Upadate time in tooltip
            var startTooltip = $("#start-tooltip");
            startTooltip.attr('data-tooltip', 'Start: ' + getTimeFromSeconds(time_options[ ui.values[ 0 ] ]));

            var endTooltip = $("#end-tooltip");
            endTooltip.attr('data-tooltip', 'End: ' + getTimeFromSeconds(time_options[ ui.values[ 1 ] ]));

            // Update the price in the visible span
            ;
            $( "#modal-selected-price" ).html( getDollarStr(getHoursFromSeconds(end_time - start_time) * info.controller.selected_prime) + " (@ " + getDollarStr(info.controller.selected_prime) + "/h)");
          }

        });

        // Initial tooltip values
        var startTooltip = $("#start-tooltip");
        startTooltip.attr('data-tooltip', 'Start: ' + getTimeFromSeconds(time_options[0]));

        var endTooltip = $("#end-tooltip");
        endTooltip.attr('data-tooltip', 'End: ' + getTimeFromSeconds(time_options[2]));        


        // Initial ice time range
        $( "#modal-selected-timerange" ).html( getTimeFromSeconds(time_options[0]) +
        " to " + getTimeFromSeconds(time_options[2]) );
        info.controller.specified_start_time = time_options[0];
        info.controller.specified_length = time_options[2] - time_options[0];

        // Initial ice time price
        var start_time = time_options[ 0 ];
        var end_time = time_options[ 2 ];

        $( "#modal-selected-price" ).html( getDollarStr(getHoursFromSeconds(end_time - start_time) * info.selected_prime)
                                          + " (@ " + getDollarStr(info.selected_prime) + "/h)");
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
        modal_body.innerHTML = '<p>By booking this ice time with the City of Kitchener you agreeing to the following policies:</p><ol><li>Rescheduling an ice time must be done at least 3 business days before the scheduled date.</li><li>Ice bookings are non-refundable.</li></ol><p>Playogo will facilitate the booking of this ice time, however any further changes or concerns must be addressed with the City of Kitchener directly.</p>';


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

        // Modal body information
        modal_body = $(modal_body);
        modal_body.children('#review-customer-name').html(info.customer_name);
        modal_body.children('#review-customer-phone').html(info.customer_phone);
        modal_body.children('#review-use-description').html(info.customer_notes);
        modal_body.children('#review-theatre').html(info.selected_venue + " - " + info.selected_theatre);
        modal_body.children('#review-date').html(getReadableDateStr(info.selected_date));
        modal_body.children('#review-time').html(getTimeFromSeconds(info.specified_start_time) + " to " + getTimeFromSeconds(info.specified_start_time + info.specified_length));

        var priceStr = getDollarStr(info.specified_price) + " (" + getHoursString(getHoursFromSeconds(info.specified_length)) + " @ " + getDollarStr(info.selected_prime) + "/hr)"; 
        modal_body.children('#review-price').html(priceStr);

        var insuranceStr = getDollarStr(info.selected_insurance) + " (manditory by municipality policy)";
        modal_body.children('#review-insurance').html(insuranceStr);

        var taxStr   = getDollarStr(info.specified_tax) + " (13% HST)";
        modal_body.children('#review-tax').html(taxStr);

        var totalCostStr   = getDollarStr(info.specified_total_cost);
        modal_body.children('#review-total-cost').html(totalCostStr); 

        // Modal button
        var modal_btn = document.getElementById('booking-modal-btn-reviewinfo');
        modal_btn.style.display = 'inline';


      } else if (state == PAYMENT) {

        var payment_form = document.getElementById('payment-form');
        var inputs = payment_form.children;

        // Fills in the following inputs
        /***************************************************
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
        ****************************************************/

        // Venue
        inputs[2].value = info.selected_venue;
        // Theatre
        inputs[3].value = info.selected_theatre;
        // Date
        inputs[4].value = info.selected_date;
        // Start time
        inputs[5].value = info.specified_start_time;
        // Length
        inputs[6].value = info.specified_length;
        // Amount
        inputs[7].value = info.specified_total_cost;
        // Nav date
        inputs[8].value = info.navigation_date;
        // Name
        inputs[9].value = info.customer_name;
        // Phone
        inputs[10].value = info.customer_phone;
        // Notes
        inputs[11].value = info.customer_notes;

        // Email filled out in stripe window


        // Close the modal
        $('#booking-modal').modal('hide');

        // Open Checkout with further options
        info.handler.open({
            name: 'Playogo.com',
            description: 'Ice time',
            amount: info.specified_total_cost
            
        });

        info.element.preventDefault();
        alert("hold here");

      }
    },

    renderMap: function () {
      initializeMap(postal);

      var container = document.getElementById('venue-container');
      var map = document.getElementById('map');
      var container_height = container.clientHeight;
      map.style.height = container_height.toString() + "px";
      google.maps.event.trigger(map, 'resize');

    },

    renderSched: function(current_date, schedule_tree, controller) {

      this.renderDatePicker(current_date, controller);
      this.renderMonthNav(current_date, controller);
      this.renderDayNav(current_date, controller);
      this.renderVenueRows(schedule_tree, current_date, controller);

    },

    /*
     * Renders the entire schedule
     * ** Currently also renders map which should be refactored
     */ 
    renderAll: function (current_date, schedule_tree, controller) {

      this.renderDatePicker(current_date, controller);
      this.renderMonthNav(current_date, controller);
      this.renderDayNav(current_date, controller);

      var self = this;
      getLatLng(postal).then(function (lat, lng) {

        sortVenueRows(schedule_tree, controller, lat, lng).then(function () {

          self.renderVenueRows(schedule_tree, current_date, controller).then(function () {

            self.renderMap();

          });

        })

      // TODO: sort out renderMap calls
      // Currently this calls proceedure that leads to aquiring lat lng again.
      });//.then(this.renderMap); 

     },

    /*
     * Callback on event
     */      
    notify: function (event_type, params) {
      if (DATE_UPDATE == event_type) {
        params.scheduleRenderer.renderSched(params.current_date, params.schedule_tree, params.controller);
      }
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