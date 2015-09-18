/*
 * Get the hour value of a 12 hour clock from the seconds since midnight
 */
var getTwelveHour = function (seconds_from_midnight) {

  var hours_from_midnight = seconds_from_midnight / (60*60);

  // Is on the hour?
  if (hours_from_midnight != parseInt(hours_from_midnight)) {
    throw "ERROR: get12hour was passed a non-hour. Times off the hour are not yet supported."

  }

  // Find string
  if (hours_from_midnight < 12) {
    hour_str = (hours_from_midnight).toString();

  } else if (hours_from_midnight == 12) {
    hour_str = '12';

  } else if (hours_from_midnight > 12 & hours_from_midnight < 24) {
    hour_str = (hours_from_midnight - 12).toString();

  } else if (hours_from_midnight == 24) {
    hour_str = '12';

  } else if (hours_from_midnight > 24 & hours_from_midnight < 30) {
    hour_str = (hours_from_midnight - 24).toString(); 

  } else {
    throw "ERROR: Invalid time in renderVenueRows()";

  }

  return hour_str;
}

/*
 * Returns a string representing a time of day.
 */
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
};

/*
 * Returns the number of hours the seconds represents
 */
function getHoursFromSeconds(seconds) {
  return seconds / 3600;
}

/*
 * Accepts float as input and outputs a string of the form "{#hours} hour{s|0}>"
 */
function getHoursString(hours) {
  if (hours === 1) {
    return hours.toString() + " hour";
  } else {
    return hours.toString() + " hours";
  }
}