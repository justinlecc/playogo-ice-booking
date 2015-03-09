'use strict'

var MONTH_NAMES = ["January", "February", "March", "April", "May", "June", 
                   "July", "August", "September", "October", "November", "December"];

// Returns monday of current day d (http://stackoverflow.com/questions/4156434/javascript-get-the-first-day-of-the-week-from-current-date)
function getMonday(d) {
  d = new Date(d);
  var day = d.getDay(),
      diff = d.getDate() - day + (day == 0 ? -6:1); // adjust when day is sunday
  return new Date(d.setDate(diff));
}

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
      content.children[0].children[0].innerHTML = MONTH_NAMES[current_date.getMonth()];

      // Week button *Need to update dropdown*
      var monday = getMonday(current_date).getDate();
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
      var start_week = getMonday(current_date);
      //start_week.setDate(getMonday(current_date));
      for (var i=1; i < tabs.length - 1; i++) {
        tabs[i].children[0].innerHTML = start_week.getDate();
        if (start_week.getDate() == current_date.getDate()) {
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
      var container = document.getElementById('hours-row-container');
      var template = document.getElementById('avails-hours-template');
      var content = document.createElement('div');
      content.innerHTML = template.innerHTML;
      var hours = content.children;

      // Fill divs with hours of day
      var time = new Date();
      var start = 6; /* hard coded start and end time */
      time.setHours(start);
      for (var i=0; i<hours.length - 1; i++) {
        var h = time.getHours();
        var postfix = '';
        if (h % 2 == start % 2) {
          postfix = ((h >= 12)? 'pm' : 'am');
        }
        hours[i].innerHTML = ((h + 11) % 12 + 1).toString() + postfix;
        if (i % 2 == 1) {
          hours[i].classList.add('odd');
        }
        time.setHours(time.getHours()+1);
      }

      container.appendChild(content);
    },

    /*
     * Renders the venue rows
     */  
    renderVenueRows: function (schedule_tree) {
      var container = document.getElementById('venue-rows-container');
      var template = document.getElementById('avails-venue-template');
      var venues = schedule_tree.venues;

      _.each(venues, function (venue) {
        var content = document.createElement('div');
        var venue_div = document.createElement('div');
        venue_div.innerHTML = venue.name;
        content.appendChild(venue_div);


        _.each(venue.theatres, function (theatre) {
          var theatre_div = document.createElement('div');
          theatre_div.innerHTML = theatre.name;
          content.appendChild(theatre_div);
        });

        container.appendChild(content);
      });
      
    },


    /*
     * Renders the entire schedule
     */ 
     renderAll: function (current_date, schedule_tree) {
      this.renderMonthNav(current_date);
      this.renderDayNav(current_date);
      this.renderHoursRow();
      this.renderVenueRows(schedule_tree);
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