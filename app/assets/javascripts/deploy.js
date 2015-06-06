'use strict'

window.addEventListener('load', function () {

  if ('WELCOME' === deploy_js) {
    deployWelcome();
  } else if ('VENUES' === deploy_js) {
    deployVenues();
  } else {
    throw "ERROR: In view js deployment, unrecognized view type.";
  }
  


});