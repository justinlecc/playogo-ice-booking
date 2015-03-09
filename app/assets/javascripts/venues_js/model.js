'use strict'

function createModelModule() {


    /*
     * VenueOpeningCollectionModel
     *     Holds venue availabilities. 
     *
    */    
    var AvailsCollectionModel = function () {
        this.listeners = [];
        this.avails = null;
    };

    _.extend(AvailsCollectionModel.prototype,{

        /* Sets the collection model's avails */
        setAvails: function (schedule_json) {
            this.avails = schedule_json;
        },

        /* Gets the collection model's avails c*/
        getAvails: function () {
            return this.avails;
        }

    });

    /*
     * Creates a AvailsCollectionModel
     */ 
    function loadAvailsCollectionModel() {
        return new AvailsCollectionModel();
    };
    


    /*
     * AvailsScheduleModel
     *     Maintains data about avails schedule. 
     *
    */
    var AvailsScheduleModel = function () {
        this.listeners = [];
        this.current_date = new Date();
        this.earliest_date = null;
        this.latest_date = null;
    };

    _.extend(AvailsScheduleModel.prototype, {
        setDateRange: function (schedule_json) {
            var earliest_date = null;
            var latest_date = null;
            _.each(schedule_json.venues, function (venue) {
                _.each(venue.theatres, function (theatre) {
                    _.each(theatre.days, function (day) {
                        var cur = new Date(day.date);
                        if (earliest_date == null && latest_date == null) {
                            earliest_date = cur;
                            latest_date = cur;
                        } else if (cur < earliest_date) {
                            earliest_date = cur;
                        } else if (cur > latest_date) {
                            latest_date = cur;
                        }
                    })
                })
            })

            this.earliest_date = earliest_date;
            this.latest_date = latest_date;
            console.log(this.earliest_date);
            console.log(this.latest_date);
        },

        getCurrentDate: function () {
            return this.current_date;
        },

        setCurrentDate: function (date) {
            this.current_date = date;
        }

    });

    /*
     * Creates an AvailScheduleModel
     */ 
    function loadAvailsScheduleModel() {
        return new AvailsScheduleModel();
    };


    // Return an object containing all of our classes and constants
    return {
        AvailsCollectionModel: AvailsCollectionModel,
        loadAvailsCollectionModel: loadAvailsCollectionModel,
        AvailsScheduleModel: AvailsScheduleModel,
        loadAvailsScheduleModel: loadAvailsScheduleModel
    };


}