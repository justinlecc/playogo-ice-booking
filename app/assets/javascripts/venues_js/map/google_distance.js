/*
 * TODO: see googlemaps.js
 */

/*
 * Sorts the VenueRows in order of proximity to lat and lng
 */

function sortVenueRows (schedule_tree, controller, lat, lng) {
	"use strict";

	var origin = new google.maps.LatLng(lat, lng);

	var deferred = $.Deferred();

	var dMatrixService = new google.maps.DistanceMatrixService();

	dMatrixService.getDistanceMatrix({
		origins: [origin],
		destinations: schedule_tree.venues.map(function (venue) {
            console.log("venue.name", venue.name, venue.lat, venue.long);
			return new google.maps.LatLng(venue.lat, venue.long);

		}),
		travelMode: google.maps.TravelMode.DRIVING
	}, function (response, status) {
		if (status === google.maps.GeocoderStatus.OK) {

			// 1) add distances and durations to schedule_tree.venues
			var elements = response.rows[0].elements;
			elements.forEach(function (el, index) {
				schedule_tree.venues[index].distance = el.distance;
				schedule_tree.venues[index].duration = el.duration;
			});
			
			// 2) sort schedule_tree.venues by distance or duration
			schedule_tree.venues.sort(function(a,b) {
				return a.duration.value >= b.duration.value;
			});

			console.log(response.rows[0].elements);
			deferred.resolve(); // schedule_tree has been sorted.
		
		} else {

			console.error("Google Distance Matrix API error: " + status);
			deferred.reject(status);
		
		}
	});
	return deferred;
}