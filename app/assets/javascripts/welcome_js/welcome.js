'use strict'

function deployWelcome () {

  /*
   * Factor out funcitonality to MVC if code becomes too large
   */

  /*
   * Search submit event
   */
  var btn   = document.getElementById("search-submit-btn");
  var input = document.getElementById("search-input");
  btn.addEventListener('click', function (e, el) {

    // Validate postal code
    if (!validPostalCode(input.value)) {

      // Display error
      document.getElementById("search-input-errors").style.display = "block";

      // Block event
      e.preventDefault();
    }

  });
  
}