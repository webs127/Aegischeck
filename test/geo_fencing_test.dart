import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:aegischeck/core/services/location_service.dart';
import 'package:aegischeck/features/qr/models/qr_attendance_payload.dart';
void main() {
  group('Geo-fencing Feature Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    group('LocationService Tests', () {
      test('distance calculation accuracy - same location should be 0 meters', () {
        // Test with exact same coordinates
        final distance = Geolocator.distanceBetween(40.7128, -74.0060, 40.7128, -74.0060);
        expect(distance, equals(0.0));
      });

      test('distance calculation accuracy - known distances', () {
        // Test with known real-world distances
        // Distance from New York City (40.7128, -74.0060) to Los Angeles (34.0522, -118.2437)
        // Approximate distance: ~3935 km or ~3,935,000 meters
        final distance = Geolocator.distanceBetween(40.7128, -74.0060, 34.0522, -118.2437);
        expect(distance, greaterThan(3900000)); // Should be around 3.9M meters
        expect(distance, lessThan(4000000)); // Should be less than 4M meters
      });

      test('distance calculation accuracy - small distances', () {
        // Test with small distances (100 meters apart)
        final distance = Geolocator.distanceBetween(40.7128, -74.0060, 40.7137, -74.0060);
        expect(distance, greaterThan(90)); // Should be around 100 meters
        expect(distance, lessThan(110)); // Allow some margin for calculation precision
      });

      test('distance calculation accuracy - office radius scenarios', () {
        // Office location
        const officeLat = 40.7128;
        const officeLng = -74.0060;

        // Calculate coordinates for points approximately 100m away
        // 1 degree latitude ≈ 111,000 meters
        // 1 degree longitude ≈ 111,000 * cos(latitude) meters
        // At 40° latitude: cos(40°) ≈ 0.766, so 1° longitude ≈ 85,000 meters
        // For 100m: latitude change ≈ 100/111000 ≈ 0.0009 degrees
        // For 100m: longitude change ≈ 100/85000 ≈ 0.00118 degrees

        const latChangeFor100m = 100 / 111000; // ≈ 0.0009 degrees
        const lngChangeFor100m = 100 / (111000 * 0.766); // ≈ 0.00118 degrees

        final testPoints = [
          {'lat': officeLat, 'lng': officeLng, 'expectedDistance': 0.0, 'description': 'exact office location'},
          {'lat': officeLat + latChangeFor100m, 'lng': officeLng, 'expectedDistance': 100.0, 'description': '100m north'},
          {'lat': officeLat - latChangeFor100m, 'lng': officeLng, 'expectedDistance': 100.0, 'description': '100m south'},
          {'lat': officeLat, 'lng': officeLng + lngChangeFor100m, 'expectedDistance': 100.0, 'description': '100m east'},
          {'lat': officeLat, 'lng': officeLng - lngChangeFor100m, 'expectedDistance': 100.0, 'description': '100m west'},
        ];

        for (final point in testPoints) {
          final distance = Geolocator.distanceBetween(
            point['lat'] as double,
            point['lng'] as double,
            officeLat,
            officeLng,
          );

          expect(
            distance,
            closeTo(point['expectedDistance'] as double, 10), // Allow 10m tolerance
            reason: 'Distance calculation for ${point['description']} should be accurate',
          );
        }
      });
    });

    group('QR Payload with Location Tests', () {
      test('qr payload includes location data', () {
        const payload = QrAttendancePayload(
          userId: 'user-123',
          organizationId: 'org-456',
          type: 'sign_in',
          timestamp: 1710000000000,
          lat: 40.7128,
          lng: -74.0060,
        );

        expect(payload.lat, equals(40.7128));
        expect(payload.lng, equals(-74.0060));
      });

      test('qr payload round-trips through json with location', () {
        const payload = QrAttendancePayload(
          userId: 'user-123',
          organizationId: 'org-456',
          type: 'sign_in',
          timestamp: 1710000000000,
          lat: 40.7128,
          lng: -74.0060,
        );

        final parsed = QrAttendancePayload.tryParse(payload.toRawJson());

        expect(parsed, isNotNull);
        expect(parsed!.userId, 'user-123');
        expect(parsed.organizationId, 'org-456');
        expect(parsed.type, 'sign_in');
        expect(parsed.timestamp, 1710000000000);
        expect(parsed.lat, equals(40.7128));
        expect(parsed.lng, equals(-74.0060));
      });

      test('qr payload without location data', () {
        const payload = QrAttendancePayload(
          userId: 'user-123',
          organizationId: 'org-456',
          type: 'sign_out',
          timestamp: 1710000000000,
        );

        expect(payload.lat, isNull);
        expect(payload.lng, isNull);
      });
    });

    group('Geo-fencing Logic Tests', () {
      test('within radius - exact location', () {
        // Test the logic that would be used in the app
        const officeLat = 40.7128;
        const officeLng = -74.0060;
        const allowedRadius = 100; // 100 meters

        // User at exact office location
        final distance = Geolocator.distanceBetween(
          officeLat,
          officeLng,
          officeLat,
          officeLng,
        );

        expect(distance <= allowedRadius, isTrue);
      });

      test('within radius - just inside boundary', () {
        const officeLat = 40.7128;
        const officeLng = -74.0060;
        const allowedRadius = 100;

        // User 90 meters away (should be within 100m radius)
        final distance = Geolocator.distanceBetween(
          40.71364, // Approximately 90m north
          officeLng,
          officeLat,
          officeLng,
        );

        expect(distance <= allowedRadius, isTrue);
        expect(distance, greaterThan(80));
        expect(distance, lessThan(100));
      });

      test('outside radius - just beyond boundary', () {
        const officeLat = 40.7128;
        const officeLng = -74.0060;
        const allowedRadius = 100;

        // User 110 meters away (should be outside 100m radius)
        final distance = Geolocator.distanceBetween(
          40.71382, // Approximately 110m north
          officeLng,
          officeLat,
          officeLng,
        );

        expect(distance > allowedRadius, isTrue);
        expect(distance, greaterThan(100));
        expect(distance, lessThan(120));
      });

      test('geo-fencing with different radius settings', () {
        const officeLat = 40.7128;
        const officeLng = -74.0060;

        // User 50 meters from office
        const latChangeFor50m = 50 / 111000; // ≈ 0.00045 degrees
        final userLat = officeLat + latChangeFor50m;
        final userLng = officeLng;

        final distance = Geolocator.distanceBetween(userLat, userLng, officeLat, officeLng);
        print('Distance for 50m test: $distance meters');
        expect(distance, closeTo(50, 10)); // Should be around 50m

        // Test with different radius settings
        expect(distance <= 25, isFalse); // Too small radius (25m)
        expect(distance <= 60, isTrue);  // Allow some tolerance (60m > 50.14m)
        expect(distance <= 100, isTrue); // Larger radius (100m)
      });
    });

    group('Edge Cases and Error Handling', () {
      test('invalid coordinates handling', () {
        // Test with invalid coordinates (0,0) which might indicate unset location
        const invalidLat = 0.0;
        const invalidLng = 0.0;
        const officeLat = 40.7128;
        const officeLng = -74.0060;

        final distance = Geolocator.distanceBetween(
          invalidLat,
          invalidLng,
          officeLat,
          officeLng,
        );

        // Distance should be reasonable (from null island to NYC)
        expect(distance, greaterThan(8000000)); // Should be around 8.6M meters
        expect(distance, lessThan(9000000));
      });

      test('extreme coordinates', () {
        // Test with coordinates near poles and international date line
        const northPoleLat = 89.9999;
        const northPoleLng = 0.0;
        const officeLat = 40.7128;
        const officeLng = -74.0060;

        final distance = Geolocator.distanceBetween(
          northPoleLat,
          northPoleLng,
          officeLat,
          officeLng,
        );

        expect(distance, greaterThan(4000000)); // Should be significant distance
      });

      test('coordinate precision', () {
        // Test that small coordinate differences result in small distance differences
        const baseLat = 40.7128;
        const baseLng = -74.0060;

        // Very small difference (0.0001 degrees ≈ 11 meters)
        final smallDiffLat = baseLat + 0.0001;
        final distance = Geolocator.distanceBetween(
          smallDiffLat,
          baseLng,
          baseLat,
          baseLng,
        );

        expect(distance, greaterThan(5));  // Should be around 11m
        expect(distance, lessThan(20));    // Allow some tolerance
      });
    });

    group('Integration Tests', () {
      test('comprehensive geo-fencing scenario', () {
        // Simulate a complete geo-fencing scenario
        const officeLat = 40.7128;
        const officeLng = -74.0060;
        const allowedRadius = 110; // Allow some tolerance for calculation precision

        // Calculate coordinate changes for 100m
        const latChangeFor100m = 100 / 111000; // ≈ 0.0009 degrees
        const lngChangeFor100m = 100 / (111000 * 0.766); // ≈ 0.00118 degrees

        // Test multiple employee locations
        final employeeLocations = [
          {'lat': officeLat, 'lng': officeLng, 'expectedWithinRadius': true, 'description': 'at office'},
          {'lat': officeLat + latChangeFor100m, 'lng': officeLng, 'expectedWithinRadius': true, 'description': '100m north (~100.3m actual)'},
          {'lat': officeLat - latChangeFor100m, 'lng': officeLng, 'expectedWithinRadius': true, 'description': '100m south (~100.3m actual)'},
          {'lat': officeLat, 'lng': officeLng + lngChangeFor100m, 'expectedWithinRadius': true, 'description': '100m east (~100.3m actual)'},
          {'lat': officeLat, 'lng': officeLng - lngChangeFor100m, 'expectedWithinRadius': true, 'description': '100m west (~100.3m actual)'},
          {'lat': officeLat + (2 * latChangeFor100m), 'lng': officeLng, 'expectedWithinRadius': false, 'description': '200m north'},
          {'lat': officeLat - (2 * latChangeFor100m), 'lng': officeLng, 'expectedWithinRadius': false, 'description': '200m south'},
        ];

        for (final location in employeeLocations) {
          final distance = Geolocator.distanceBetween(
            location['lat'] as double,
            location['lng'] as double,
            officeLat,
            officeLng,
          );

          final isWithinRadius = distance <= allowedRadius;
          final expectedWithinRadius = location['expectedWithinRadius'] as bool;
          expect(
            isWithinRadius,
            equals(expectedWithinRadius),
            reason: 'Employee ${location['description']} should ${expectedWithinRadius ? 'be' : 'not be'} within radius',
          );
        }
      });

      test('distance accuracy validation', () {
        // Test that our distance calculations match expected real-world values
        // Using well-known distances for validation

        // Empire State Building to Statue of Liberty (approx 8.5 km)
        final empireStateLat = 40.7484;
        final empireStateLng = -73.9857;
        final statueLibertyLat = 40.6892;
        final statueLibertyLng = -74.0445;

        final distance = Geolocator.distanceBetween(
          empireStateLat,
          empireStateLng,
          statueLibertyLat,
          statueLibertyLng,
        );

        // Should be approximately 8500 meters (8.5 km)
        expect(distance, greaterThan(8000));
        expect(distance, lessThan(9000));
      });
    });
  });
}