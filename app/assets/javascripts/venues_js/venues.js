'use strict'

/*
 * Controller states (explanation of each below)
 */
var SEARCH = 'SEARCH';
var TIME_SELECT = 'TIME_SELECT';
var VENUE_POLICIES = 'VENUE_POLICIES';
var INPUT_INFO = 'INPUT_INFO';
var REVIEW_INFO = 'REVIEW_INFO';
var PAYMENT = 'PAYMENT';


function deployVenues () {

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
    availsScheduleModel.controller = venueController;

    


    /////////////////////////////////////////////////////////////////////
    // MODAL

    /*
     * Add event listeners to TIME_SELECT modal
     */

    // TIME_SELECT continue
    var timeselect_continue_btn = document.getElementById('booking-modal-btn-timeselect').children[1];
    timeselect_continue_btn.addEventListener('click', function () {

        venueController.changePageState(null, VENUE_POLICIES);
    });

    /*
     * Add event listeners to VENUE_POLICIES modal
     */

    // VENUE_POLICIES back and continue
    var venuepolicies_back_btn = document.getElementById('booking-modal-btn-venuepolicies').children[0];
    venuepolicies_back_btn.addEventListener('click', function () {
        venueController.changePageState(null, TIME_SELECT);
    });

    var venuepolicies_continue_btn = document.getElementById('booking-modal-btn-venuepolicies').children[1];
    venuepolicies_continue_btn.addEventListener('click', function () {
        venueController.changePageState(null, INPUT_INFO);
    });

    /*
     * Add event listeners to INPUT_INFO modal
     */

    // INPUT_INFO back and continue
    var inputinfo_back_btn = document.getElementById('booking-modal-btn-inputinfo').children[0];
    inputinfo_back_btn.addEventListener('click', function () {
        venueController.changePageState(null, VENUE_POLICIES);
    });
    var inputinfo_continue_btn = document.getElementById('booking-modal-btn-inputinfo').children[1];
    inputinfo_continue_btn.addEventListener('click', function () {



        // Get info
        var customer_name = $( '#customer-name' ).val();
        var customer_phone = $( '#customer-phone' ).val();
        var customer_notes = $( '#customer-notes' ).val();

        // Check form of input
        // **Currently only checks if a string has been inputed
        var invalid_input = false;

        if (customer_name === "") {
            invalid_input = true;
            document.getElementById("input-info-name-error").style.display = "block";
        } else {
            document.getElementById("input-info-name-error").style.display = "none";
        }

        if (customer_phone === "") {
            invalid_input = true;
            document.getElementById("input-info-phone-error").style.display = "block";
        } else {
            document.getElementById("input-info-phone-error").style.display = "none";
        }

        if (customer_notes === "") {
            invalid_input = true;
            document.getElementById("input-info-description-error").style.display = "block";
        } else {
            document.getElementById("input-info-phone-error").style.display = "none";
        }

        // If argument is missing, do not proceed
        if (invalid_input) {
            return;
        }


        // Update controller
        venueController.customer_name = customer_name;
        venueController.customer_phone = customer_phone;
        venueController.customer_notes = customer_notes;

        // Change the current page
        venueController.changePageState(null, REVIEW_INFO);
    });

    /*
     * Add event listeners to REVIEW_INFO modal
     */

    // REVIEW_INFO back button
    var reviewinfo_back_btn = document.getElementById('booking-modal-btn-reviewinfo').children[0];
    reviewinfo_back_btn.addEventListener('click', function () {
        venueController.changePageState(null, INPUT_INFO);
    });

    // REVIEW_INFO payment button
    var reviewinfo_continue_btn = document.getElementById('booking-modal-btn-reviewinfo').children[1];
    reviewinfo_continue_btn.addEventListener('click', function (e) {
        venueController.changePageState(e, PAYMENT);
    });

};