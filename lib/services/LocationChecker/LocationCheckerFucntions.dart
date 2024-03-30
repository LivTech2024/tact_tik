import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// class UserLocationChecker {
// Future<bool> checkLocation(
//     double _shiftLatitude, double _shiftLongitude, int radius) async {
//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied ||
//       permission == LocationPermission.deniedForever) {
//     LocationPermission ask = await Geolocator.requestPermission();
//     return false;
//   } else {
//     Position currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     double distanceInMeters = Geolocator.distanceBetween(
//         currentPosition.latitude,
//         currentPosition.longitude,
//         _shiftLatitude,
//         _shiftLongitude);
//     print("Latitude :${currentPosition.latitude}");

//     print("Longitude: ${currentPosition.longitude}");
//     print("Shift Latitude :${_shiftLatitude}");
//     print("shift Latitude :${_shiftLongitude}");

//     if (distanceInMeters <= radius) {
//       return true; // Within shift location radius
//     } else {
//       return false; // Outside shift location radius
//     }
//   } // Permission not granted
// }

// }

class UserLocationChecker {
  Future<bool> checkLocation(
      double _shiftLatitude, double _shiftLongitude, int radius) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        LocationPermission ask = await Geolocator.requestPermission();
        permission = ask;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false; // Permission not granted
      } else {
        Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double distanceInMeters = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            _shiftLatitude,
            _shiftLongitude);
        print("Radius: ${radius}");

        print("Latitude: ${currentPosition.latitude}");
        print("Longitude: ${currentPosition.longitude}");
        print("Shift Latitude: $_shiftLatitude");
        print("Shift Longitude: $_shiftLongitude");
        print("Distance Meters: ${distanceInMeters}");
        if (distanceInMeters <= radius) {
          return true; // Within shift location radius
        } else {
          return false; // Outside shift location radius
        }
      }
    } catch (e) {
      print("Error getting location: $e");
      return false;
    }
  }
}
