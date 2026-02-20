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

// Distance between NY and Malaysia
console.log(distanceInKmBetweenEarthCoordinates(40.7128, -74.0060, 3.1390, 101.6869));
// Distance between SF and Malaysia
console.log(distanceInKmBetweenEarthCoordinates(37.7749, -122.4194, 3.1390, 101.6869));
