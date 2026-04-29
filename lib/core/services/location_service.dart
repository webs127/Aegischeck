import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<bool> requestPermission() async {
    // First check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, can't proceed
      return false;
    }

    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  Future<Position?> getCurrentPosition() async {
    if (!await requestPermission()) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<Map<String, double>?> getCurrentLocation() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    return {
      'lat': position.latitude,
      'lng': position.longitude,
    };
  }

  Future<bool> isWithinRadius(
    double orgLat,
    double orgLng,
    int allowedRadius,
  ) async {
    final position = await getCurrentPosition();
    if (position == null) return false;

    // Reject if accuracy is poor
    if (position.accuracy > 50) return false;

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      orgLat,
      orgLng,
    );

    return distance <= allowedRadius;
  }
}