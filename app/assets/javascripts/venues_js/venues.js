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
var REVIEW_INFO = 'REVIEW_INFO';
var PAYMENT = 'PAYMENT';


window.addEventListener('load', function() {
    alert(deploy_js);

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
        // Get info update controller
        var customer_name = $( '#customer-name' ).val();
        venueController.customer_name = customer_name;

        var customer_phone = $( '#customer-phone' ).val();
        venueController.customer_phone = customer_phone;

        var customer_notes = $( '#customer-notes' ).val();
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
        venueController.changePageState(null, VENUE_POLICIES);
    });

    // REVIEW_INFO payment button
    var reviewinfo_continue_btn = document.getElementById('booking-modal-btn-reviewinfo').children[1];
    reviewinfo_continue_btn.addEventListener('click', function (e) {
        venueController.changePageState(e, PAYMENT);
    });

    // Set up stripe handler
    // var payment_submited = false;
    // var handler = StripeCheckout.configure({
    //     key: 'pk_test_1Di5chkNtgIMHyHZ6pbKLOrD',
    //     token: function(token) {
    //         payment_submited = true;
    //         alert("TOKEN - payment_submited: " + payment_submited.toString());
    //         // Update form
    //         $( 'input[name="stripeToken"]' ).val(token.id);
    //         $( 'input[name="stripeEmail"]' ).val(token.email);

    //         //alert($( 'input[name="stripeEmail"]' ).val(token.email));

    //         // Submit the form
    //         document.getElementById('payment-form').submit();
    //     },
    //     closed: function () {
    //         alert("CLOSED - payment_submited: " + payment_submited.toString());
    //         if (payment_submited == true) {
    //             payment_submited = false;
    //         } else {
    //             $('#booking-modal').modal('show');
    //             venueController.changePageState(null, REVIEW_INFO);
    //         }
    //     }

    // });

    // // REVIEW_INFO pay button
    // $('#stripe-checkout-btn').on('click', function(e) {
    //     venueController.changePageState(null, PAYMENT);
    //     // Open Checkout with further options
    //     handler.open({
    //         name: 'Playogo.com',
    //         description: 'Ice time',
    //         amount: 2000,
            
    //     });
    //     e.preventDefault();
    // });

    // // Close Checkout on page navigation
    // $(window).on('popstate', function() {
    //     handler.close();
    // });


});