

function createModelModule() {


    /*
     * VenueOpeningCollectionModel
     *     Holds venue availabilities. 
     *
    */    
    var VenueOpeningCollectionModel = function () {
        this.listeners = [];
        this.venue_openings = [];
    };

    _.extend(VenueOpeningCollectionModel.prototype,{
        test: function () {
            alert("test");
        }


    });

    /*
     * Creates a VenueOpeningCollectionModel
     */ 
    function loadVenueOpeningCollectionModel() {
        return new VenueOpeningCollectionModel();
    };
    


    /*
     * OpeningScheduleModel
     *     Maintains data about opening schedule. 
     *
    */
    var OpeningScheduleModel = function () {
        this.listeners = [];
        this.current_date = null;
        this.earliest_date = null;
        this.latest_date = null;
    };

    _.extend(OpeningScheduleModel.prototype, {



    });


    // Return an object containing all of our classes and constants
    return {
        VenueOpeningCollectionModel: VenueOpeningCollectionModel,
        loadVenueOpeningCollectionModel: loadVenueOpeningCollectionModel,
        OpeningScheduleModel: OpeningScheduleModel
    };


}