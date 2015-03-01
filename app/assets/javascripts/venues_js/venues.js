// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
// window.addEventListener 'load', ->
//   alert 'Hello solo!'
//   return

window.addEventListener('load', function() {

    var modelModule = new createModelModule();

    /*
     * Initialize the VenueOpeningCollectionModel
     */
    var venueOpeningCollectionModel = modelModule.loadVenueOpeningCollectionModel();
    venueOpeningCollectionModel.setOpenings(json_schedule_tree()); // json_schedule_tree initialized in rendering



});