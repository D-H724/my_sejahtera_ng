import 'dart:math';

// Simplified haversine formula for distance between
double distance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
}

void main() {
  double lat1 = 3.1390;
  double lon1 = 101.6869;
  double lat2 = 3.1729;
  double lon2 = 101.7018;

  print(distance(lat1, lon1, lat2, lon2));
}
