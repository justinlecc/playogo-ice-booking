// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
// window.addEventListener 'load', ->
//   alert 'Hello solo!'
//   return
'use strict'

/*
 * Controller states (explanation of each below)
 */
var SEARCH = 'SEARCH';
var TIME_SELECT = 'TIME_SELECT';
var VENUE_POLICIES = 'VENUE_POLICIES';
var INPUT_INFO = 'INPUT_INFO';
var PAYMENT = 'PAYMENT';


window.addEventListener('load', function() {
    var modelModule = new createModelModule();
    var viewModule = new createViewModule();
    var controllerModule = new createControllerModule();

    /*
     * Initialize the VenueOpeningCollectionModel
     */
    var availsCollectionModel = modelModule.loadAvailsCollectionModel();

    /*
     * Initialize the AvailsScheduleModel
     */
    var availsScheduleModel = modelModule.loadAvailsScheduleModel();

    /*
     * Initialize the ScheduleRenderer
     */
    var scheduleRenderer = viewModule.loadScheduleRenderer();

    /*
     * Initialize the VenueController
     */
    var venueController = controllerModule.loadVenueController(availsCollectionModel, availsScheduleModel, scheduleRenderer);
    venueController.initializePage(schedule_tree); // schedule_tree from .erb view rendering

    /*
     * Add event listeners
     */
    // Click on avail block
    _.each($('.avail-block'), function (el) {
        el.addEventListener('click', function () {
            venueController.changePageState(this, TIME_SELECT);
        });
    });

    // TIME_SELECT continue
    var timeselect_continue_btn = document.getElementById('booking-modal-btn-timeselect').children[1];
    timeselect_continue_btn.addEventListener('click', function () {
        venueController.changePageState(null, VENUE_POLICIES);
    });

    // VENUE_POLICIES back and continue
    var venuepolicies_back_btn = document.getElementById('booking-modal-btn-venuepolicies').children[0];
    venuepolicies_back_btn.addEventListener('click', function () {
        venueController.changePageState(null, TIME_SELECT);
    });

    var venuepolicies_continue_btn = document.getElementById('booking-modal-btn-venuepolicies').children[1];
    venuepolicies_continue_btn.addEventListener('click', function () {
        venueController.changePageState(null, INPUT_INFO);
    });

    // INPUT_INFO back and continue
    var inputinfo_back_btn = document.getElementById('booking-modal-btn-inputinfo').children[0];
    inputinfo_back_btn.addEventListener('click', function () {
        venueController.changePageState(null, VENUE_POLICIES);
    });

});