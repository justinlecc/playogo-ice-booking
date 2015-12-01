'use strict'

function createModelModule() {

    /*
     * Event types
     */
    var DATE_UPDATE = 'DATE_UPDATE';


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
        this.controller = null;

        this.listeners = [];

        // Get current date according to local timezone, convert to have UTC, and get dateless string from it
        var date = new Date();
        date = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes()));
        this.current_date = datelessString(date);

        // Initialize the date range of availabilities we have
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
                        var cur = day.date;
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
        },

        /*
         * Returns the date currently being navigated
         */
        getCurrentDate: function () {
            return this.current_date;
        },

        /*
         * Sets the date currently being navigated
         */
        setCurrentDate: function (date) {
            this.current_date = date;
            // if statement for testing (set current date being used on initialization)
            if (this.controller != null) {
                this.notifyListeners(DATE_UPDATE, null);
            }
        },

        /*
         * Add listener to AvailsScheduleModel
         */
        addListener: function (listener) {
            this.listeners.push(listener);
        },

        /*
         * Call callback listeners with event type and neccessary params
         */
        notifyListeners: function (event_type, params) {
            var self = this;
            _.each(self.listeners, function (l) {
                l(event_type, {controller: self.controller});
            })
        }

    });

    /*
     * Creates an AvailScheduleModel
     */ 
    function loadAvailsScheduleModel() {
        return new AvailsScheduleModel();
    };



    /*
     * MapModel
     *     Holds information about the map 
     *
    */    
    var MapModel = function () {
        this.listeners = [];
        this.postal    = '';
    };

    _.extend(MapModel.prototype,{

        /* Sets the map's postal code */
        setPostal: function (postal) {
            this.postal = postal;
        },

        /* Get the map's postal code */
        getPostal: function () {
            return this.postal;
        },

        /*
         * Add listener to AvailsScheduleModel
         */
        addListener: function (listener) {
            this.listeners.push(listener);
        },

        /*
         * Call callback listeners with event type and neccessary params
         */
        notifyListeners: function (event_type, params) {
            var self = this;
            _.each(self.listeners, function (l) {
                l(event_type, {controller: self.controller});
            })
        }

    });

    /*
     * Creates a MapModel
     */ 
    function loadMapModel() {
        return new MapModel();
    };


    /*
     * Return an object containing all of our classes and constants
     */
    return {
        AvailsCollectionModel:     AvailsCollectionModel,
        loadAvailsCollectionModel: loadAvailsCollectionModel,
        AvailsScheduleModel:       AvailsScheduleModel,
        loadAvailsScheduleModel:   loadAvailsScheduleModel,
        loadMapModel:              loadMapModel
    };


}