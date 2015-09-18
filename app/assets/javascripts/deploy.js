'use strict'

/*
 * Deploys the desired javascript for the page specified by 'deploy_js'.
 *     Currently all assets are being served via the asset pipeline.
 *     To improve efficiency, specify which assets are being served to each page.
 */


window.addEventListener('load', function () {

  if ('WELCOME' === deploy_js) {
    deployWelcome();
  } else if ('VENUES' === deploy_js) {
    deployVenues();
  } else {
    throw "ERROR: In view js deployment, unrecognized view type.";
  }
  
});