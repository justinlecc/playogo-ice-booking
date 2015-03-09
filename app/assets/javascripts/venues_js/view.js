'use strict'

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
    renderVenueRows: function (schedule_tree) {
      var container = document.getElementById('venue-rows-container');
      //var template = document.getElementById('avails-venue-template');
      var venues = schedule_tree.venues;

      _.each(venues, function (venue) {
        var venue_row = document.createElement('div');
        venue_row.className = 'venue-row';
        var name_col = document.createElement('div');
        name_col.className = 'name-col'
        name_col.style.width = NAME_COL_WIDTH_PCT.toString() + '%'
        name_col.innerHTML = venue.name;
        venue_row.appendChild(name_col);

        var sched_col = document.createElement('div');
        sched_col.className = 'sched-col';
        sched_col.style.width = (100-NAME_COL_WIDTH_PCT).toString() + '%';
        venue_row.appendChild(sched_col);

        var clearfix = document.createElement('div');
        clearfix.className = 'clearfix';
        venue_row.appendChild(clearfix);

        container.appendChild(venue_row);


        // _.each(venue.theatres, function (theatre) {
        //   // var theatre_div = document.createElement('div');
        //   // theatre_div.innerHTML = theatre.name;
        //   // content.appendChild(theatre_div);
        // });

        //container.appendChild(row);
      });
      
    },


    /*
     * Renders the entire schedule
     */ 
     renderAll: function (current_date, schedule_tree) {
      this.renderMonthNav(current_date);
      this.renderDayNav(current_date);
      //this.renderHoursRow();
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