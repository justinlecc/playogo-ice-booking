function initializeMap (postalCode) {

  var LAT_LONG_RECIEVED = false;

  // Get lat long from postal code
  var lat = '';
  var lng = '';
  var address = postalCode;

  var geocoder;
  geocoder = new google.maps.Geocoder();
  alert(geocoder);
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
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var map = new google.maps.Map(document.getElementById('map'), mapOptions);

  // Set customer location marker and info window
  var markerOptions = {
    position: new google.maps.LatLng(lat, long)
  }
  var marker = new google.maps.Marker(markerOptions);
  marker.setMap(map);

  var infoWindowOptions = {
    content: 'Your location.'
  };
  var infoWindow = new google.maps.InfoWindow(infoWindowOptions);
  google.maps.event.addListener(marker, 'click', function(e){
    infoWindow.open(map, marker);
  });

  // Set venue markers
  //alert(schedule_tree.venues);

}