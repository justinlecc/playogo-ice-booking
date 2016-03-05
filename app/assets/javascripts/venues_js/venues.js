'use strict'

/*
 * Controller states (explanation of each below)
 */
var SEARCH         = 'SEARCH';
var TIME_SELECT    = 'TIME_SELECT';
var VENUE_POLICIES = 'VENUE_POLICIES';
var INPUT_INFO     = 'INPUT_INFO';
var REVIEW_INFO    = 'REVIEW_INFO';
var PAYMENT        = 'PAYMENT';


function deployVenues () {
    /*
     * Initialize modules
     */
    var modelModule = new createModelModule();
    var viewModule = new createViewModule();
    var controllerModule = new createControllerModule();

    /*
     * Initialize the AvailsCollectionModel
     */
    var availsCollectionModel = modelModule.loadAvailsCollectionModel();

    /*
     * Initialize the AvailsScheduleModel
     */
    var availsScheduleModel = modelModule.loadAvailsScheduleModel();

    /*
     * Initialize the MapModel
     */
    var mapModel = modelModule.loadMapModel();    

    /*
     * Initialize the ScheduleRenderer
     */
    var scheduleRenderer = viewModule.loadScheduleRenderer();

    /*
     * Initialize the UseTracker
     */
    var useTracker = new UseTracker();

    /*
     * Initialize the VenueController
     */
    var venueController = controllerModule.loadVenueController(availsCollectionModel, availsScheduleModel, mapModel, scheduleRenderer, useTracker);
    venueController.initializePage();
    availsScheduleModel.controller = venueController;


    /////////////////////////////////////////////////////////////////////
    // MODAL EVENTS

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
        var customer_name     = $('#customer-name').val();
        var customer_address  = $('#customer-address').val();
        var customer_city     = $('#customer-city').val();
        var customer_province = $('#customer-province').val();
        var customer_country  = $('#customer-country').val();
        var customer_postal   = $('#customer-postal').val();
        var customer_phone    = $('#customer-phone').val();
        var customer_notes    = $('#customer-notes').val();

        // Check form of input
        // TODO: Currently only checks if a string has been inputed
        var invalid_input = false;

        if (customer_name === "") {
            invalid_input = true;
            document.getElementById("input-info-name-error").style.display = "block";
        } else {
            document.getElementById("input-info-name-error").style.display = "none";
        }

        if (customer_address === "") {
            invalid_input = true;
            document.getElementById("input-info-address-error").style.display = "block";
        } else {
            document.getElementById("input-info-address-error").style.display = "none";
        }

        if (customer_city === "") {
            invalid_input = true;
            document.getElementById("input-info-city-error").style.display = "block";
        } else {
            document.getElementById("input-info-city-error").style.display = "none";
        }

        if (customer_province === "") {
            invalid_input = true;
            document.getElementById("input-info-province-error").style.display = "block";
        } else {
            document.getElementById("input-info-province-error").style.display = "none";
        }

        if (customer_country === "") {
            invalid_input = true;
            document.getElementById("input-info-country-error").style.display = "block";
        } else {
            document.getElementById("input-info-country-error").style.display = "none";
        }

        if (customer_postal === "") {
            invalid_input = true;
            document.getElementById("input-info-postal-error").style.display = "block";
        } else {
            document.getElementById("input-info-postal-error").style.display = "none";
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
        venueController.customer_name     = customer_name;
        venueController.customer_address  = customer_address;
        venueController.customer_city     = customer_city;
        venueController.customer_province = customer_province;
        venueController.customer_country  = customer_country;
        venueController.customer_postal   = customer_postal;
        venueController.customer_phone    = customer_phone;
        venueController.customer_notes    = customer_notes;

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
        venueController.changePageState({el: e}, PAYMENT);
    });

    /*
     * Track google maps clicks.
     */
    var map = document.getElementById('map');
    map.addEventListener('click', function () {
        useTracker.submitAction("GOOGLE_MAP_MARKER_CLICK");
    });
    
};