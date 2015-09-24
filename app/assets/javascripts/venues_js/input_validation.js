/*
 * Returns true if postalCode is well formed
 */

function validPostalCode(postalCode) {

  // Remove spaces
  postalCode = postalCode.replace(/ /g, '');
  console.log(postalCode);

  // Check length
  if (postalCode.length != 6) {
    console.log("length");
    return false;
  }

  // Check letters
  // ** This is a weak check but picks up on most common mistakes
  if (!(isNaN(postalCode[0])) ||
      !(isNaN(postalCode[2])) ||
      !(isNaN(postalCode[4]))) {
    return false;
  }

  // Check numbers
  if ((isNaN(postalCode[1])) ||
      (isNaN(postalCode[3])) ||
      (isNaN(postalCode[5]))) {
    console.log("number");
    return false;
  }

  return true;

}