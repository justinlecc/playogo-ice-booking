// returns a jQuery Defferend object
function getLatLng(address) {
  var geocoder = new google.maps.Geocoder();
  var deferred = $.Deferred();

  geocoder.geocode( { 'address': address}, function (results, status) {
    if (status === google.maps.GeocoderStatus.OK) {
      lat = results[0].geometry.location.lat();
      lng = results[0].geometry.location.lng();
      deferred.resolve(lat, lng);
    } else {
      alert("Geocode was not successful for the following reason: " + status);
      deferred.reject(status);
    }
  });
  return deferred;
}



function initializeMap (postalCode) {

  var LAT_LONG_RECIEVED = false;

  // Get lat long from postal code
  var lat = '';
  var lng = '';
  var address = postalCode;

  var geocoder;
  geocoder = new google.maps.Geocoder();

  geocoder.geocode( { 'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      lat = results[0].geometry.location.lat();
      lng = results[0].geometry.location.lng();
      renderMap(lat, lng);
    } else {
      alert("Geocode was not successful for the following reason: " + status);
    }
  });

}

function renderMap (lat, long) {

  // Display map
  var mapOptions = {
    center: new google.maps.LatLng(lat, long),
    zoom: 10,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var map = new google.maps.Map(document.getElementById('map'), mapOptions);

  // Set customer location marker
  var markerOptions = {
    position: new google.maps.LatLng(lat, long)
  }
  var marker = new google.maps.Marker(markerOptions);
  marker.setMap(map);

  // Set customer info window
  var infoWindowOptions = {
    content: 'Your location.'
  };
  var infoWindow = new google.maps.InfoWindow(infoWindowOptions);
  google.maps.event.addListener(marker, 'click', function(e){
    infoWindow.open(map, marker);
  });

  // Iterate through venues
  var vMarkers = [];
  var vInfoWindows = [];
  // To solve closure problem (http://stackoverflow.com/questions/2670356/looping-through-markers-with-google-maps-api-v3-problem)
  function makeInfoWindowEvent(map, infowindow, marker) {  
    return function() {  
      infowindow.open(map, marker);
    };  
  }

  for (var i=0; i<schedule_tree.venues.length; i++) {
    var vlat = schedule_tree.venues[i].lat;
    var vlong = schedule_tree.venues[i].long;
    var vaddr = schedule_tree.venues[i].address;

    
    // Set venue marker
    var vMarkerOptions = {
      position: new google.maps.LatLng(vlat, vlong),
      icon: '/assets/playogoMarker3.png'
    }
    var vMarker = new google.maps.Marker(vMarkerOptions);
    vMarker.setMap(map);
    vMarkers.push(vMarker);

    // Set venue info window
    var vInfoWindowOptions = {
      content: schedule_tree.venues[i].name + '<br>' + schedule_tree.venues[i].address
    };
    var vInfoWindow = new google.maps.InfoWindow(vInfoWindowOptions);
    vInfoWindows.push(vInfoWindow);

    google.maps.event.addListener(vMarker, 'click', makeInfoWindowEvent(map, vInfoWindows[i], vMarkers[i]));
  }


  // Set venue markers
  // _.each(schedule_tree.venues, function(venue) {
  //   var vlat = venue.lat;
  //   var vlong = venue.long;
  //   var vaddr = venue.address;
  //   console.log(venue.name);

  //   var markerOptions2 = {
  //     position: new google.maps.LatLng(lat, long)
  //   }
  //   var marker2 = new google.maps.Marker(markerOptions2);
  //   marker2.setMap(map);

  // });

}