/////////////////////////////////////////////////////////////////////
// BOOKING_PRICING

/*
 * This following model works for Kitchener but will need to be elaborated for
 * more complex pricing structures.
 */

/*
 * Cutoff time between prime and non-prime ice on weekdays (weekends all prime).
 * 5:00PM prime ice starts
 */
var START_PRIME = 17 * 60 * 60; // 5:00pm in seconds

function getBookingPrice(date, startTime, length, prime, nonPrime) {

  var dateObj = parseUTCDate(date);
  var dayOfWeek = dateObj.getUTCDay();

  // The whole booking is prime ice
  if (dayOfWeek === 0 || dayOfWeek === 6 || startTime >= START_PRIME) {
    return prime * getHoursFromSeconds(length);
  }

  // The whole booking is non prime ice
  else if (startTime+length <= START_PRIME) {
    return nonPrime * getHoursFromSeconds(length);
  }

  // The icetime is partly prime and partly non prime
  else {

    // Get cost of non prime ice
    var nonPrimeAmount = getHoursFromSeconds(START_PRIME - startTime) * nonPrime;

    // Get cost of prime ice
    var primeAmount    = getHoursFromSeconds((startTime + length) - START_PRIME) * prime;

    return nonPrimeAmount + primeAmount;

  }
}