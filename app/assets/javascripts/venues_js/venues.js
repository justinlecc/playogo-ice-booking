// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
// window.addEventListener 'load', ->
//   alert 'Hello solo!'
//   return
'use strict'

window.addEventListener('load', function() {
    var modelModule = new createModelModule();
    var viewModule = new createViewModule();

    /*
     * Initialize the VenueOpeningCollectionModel
     */
    var availsCollectionModel = modelModule.loadAvailsCollectionModel();
    availsCollectionModel.setAvails(schedule_tree); // schedule_tree from .erb view rendering

    /*
     * Initialize the AvailsScheduleModel
     */
    var availsScheduleModel = modelModule.loadAvailsScheduleModel();
    availsScheduleModel.setDateRange(availsCollectionModel.getAvails());

    /*
     * Initialize the ScheduleRenderer
     */
    var scheduleRenderer = viewModule.loadScheduleRenderer();
    scheduleRenderer.renderAll(availsScheduleModel.getCurrentDate(), availsCollectionModel.getAvails());
});