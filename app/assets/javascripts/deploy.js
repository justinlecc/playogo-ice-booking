'use strict'

/*
 * Deploys the desired javascript for the page specified by 'deploy_js'.
 *     Currently all assets are being served via the asset pipeline.
 *     To improve efficiency, specify which assets are being served to each page.
 */


window.addEventListener('load', function () {

  // Welcome page
  if ('WELCOME' === deploy_js) {
    deployWelcome();

  // Venues page
  } else if ('VENUES' === deploy_js) {
    deployVenues();

  // Manager confirm booking page
  } else if ('MANAGER/CONFIRM_BOOKING' === deploy_js) {
     // Currently no javascript to deploy

  // About page
  } else if ('ABOUT' === deploy_js) {
    // Currently no javascript to deploy

  // Contact page
  } else if ('CONTACT' === deploy_js) {
    // Currently no javascript to deploy
  
  } else {
    throw "ERROR: In view js deployment, unrecognized view type.";
  }
  
});