var MONTH_NAMES = ["January", "February", "March", "April", "May", "June", 
                   "July", "August", "September", "October", "November", "December"];

var DAYS_OF_WEEK = ["M", "T", "W", "T", "F", "S", "S"];

// Allows dates to return the number of days in its month
Date.prototype.monthDays= function(){
    var d= new Date(this.getFullYear(), this.getMonth()+1, 0);
    return d.getDate();
}

/*
 * Returns a formated date of "January 1 2000" from "yyyy-mm-dd"
 */
function getReadableDateStr(dateStr) {

  var date  = dateStr.split('-');
  var monthName = MONTH_NAMES[ parseInt(date[1]) - 1 ];
  var day = date[2];

  // 'st' postfix
  if (parseInt(day) === 1 || parseInt(day) === 21 || parseInt(day) === 31) {
    day = parseInt(day).toString() + "st";

  // 'nd' postfix
  } else if (parseInt(day) === 2 || parseInt(day) === 22) {
    day = parseInt(day).toString() + "nd";

  // 'rd' postfix
  } else if (parseInt(day) === 3 || parseInt(day) === 23) {
    day = parseInt(day).toString() + "rd";

  // 'th' postfix
  } else {
    day = parseInt(day).toString() + "th";
  }

  return monthName + " " + day + " " + date[0];
}

/*
 * Returns monday of current day d (http://stackoverflow.com/questions/4156434/javascript-get-the-first-day-of-the-week-from-current-date)
 */
function getMonday(d) {
  d = new Date(d);
  var day = d.getUTCDay(),
      diff = d.getUTCDate() - day + (day == 0 ? -6:1); // adjust when day is sunday
  return new Date(d.setUTCDate(diff));
}

/*
 * parse a date in yyyy-mm-dd format to UTC time
 * WARNING: typically UTC time is being used as an object naive to timezones. In
 * these cases, be sure to use UTC 'getter methods'. Eg. .getUTCday().
 */
function parseUTCDate(input) {
  var parts = input.split('-');
  // new Date(year, month [, day [, hours[, minutes[, seconds[, ms]]]]])
  return new Date(Date.UTC(parts[0], parts[1]-1, parts[2],0,0,0,0)); // Note: months are 0-based
}

/*
 * Pads integer with 0 if less than 10
 */
function toPaddedString(num) {
  if (num < 10) {
    return '0' + parseInt(num);
  } else {
    return parseInt(num);
  }
}

/*
 * Get a new date object incremented by days
 */
Date.prototype.addDays = function(days)
{
    var dat = new Date(this.valueOf());
    dat.setDate(dat.getDate() + days);
    return dat;
}

/*
 * Get a dateless string from date object
 */
var datelessString = function (date) {
  var year = date.getUTCFullYear();
  year = year.toString();
  var month = date.getUTCMonth() + 1; // January is zero
  if (month < 10) {
      month = '0' + month.toString();
  } else {
      month = month.toString();
  }
  var day = date.getUTCDate();
  if (day < 10) {
      day = '0' + day.toString();
  } else {
      day = day.toString();
  }

  return year + "-" + month + "-" + day;
};