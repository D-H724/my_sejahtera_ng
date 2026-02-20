function distanceInKmBetweenEarthCoordinates(lat1, lon1, lat2, lon2) {
  var earthRadiusKm = 6371;

  var dLat = (lat2-lat1) * Math.PI / 180;;
  var dLon = (lon2-lon1) * Math.PI / 180;;

  lat1 = lat1 * Math.PI / 180;;
  lat2 = lat2 * Math.PI / 180;;

  var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
          Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  return earthRadiusKm * c;
}

// Distance between Mountain view (Googleplex default)
console.log(distanceInKmBetweenEarthCoordinates(37.4220, -122.0840, 3.1390, 101.6869));
