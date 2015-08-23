// Returns a dollar string from cents integer
function getDollarStr(cents){
  var dollars         = parseInt(cents / 100);
  var remaining_cents = Math.round(cents % 100);
  if (remaining_cents < 10) {
    remaining_cents = "0" + remaining_cents;
  }

  return "$" + dollars.toString() + "." + remaining_cents.toString();
}