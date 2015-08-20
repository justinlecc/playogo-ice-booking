// make hour (12 hour clock)
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