import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/services/location_service.dart';

import '../models/qr_attendance_action.dart';
import '../models/qr_attendance_payload.dart';
import '../models/qr_attendance_result.dart';
import 'attendance_policy_utils.dart';
import 'qr_attendance_service.dart';

class QrAttendanceServiceImpl implements QrAttendanceService {
  final FirebaseFirestore _firestore;

  QrAttendanceServiceImpl(this._firestore);

  bool _isAuthorizedScanner(String role) {
    final normalizedRole = role.trim().toLowerCase();
    return normalizedRole == 'admin' || normalizedRole.contains('admin');
  }

  @override
  Future<QrAttendanceResult> validateAndRecordAttendance({
    required String rawQrPayload,
    required String scannerUserId,
    required String scannerOrganizationId,
    required String scannerRole,
  }) async {
    try {
      if (scannerUserId.trim().isEmpty ||
          scannerOrganizationId.trim().isEmpty ||
          !_isAuthorizedScanner(scannerRole)) {
        return QrAttendanceResult.unauthorized();
      }

      final payload = QrAttendancePayload.tryParse(rawQrPayload);
      if (payload == null) {
        return QrAttendanceResult.invalidPayload();
      }

      if (payload.isExpired()) {
        return QrAttendanceResult.expired();
      }

      if (payload.organizationId.trim() != scannerOrganizationId.trim()) {
        return QrAttendanceResult.invalidOrganization();
      }

      final action = QrAttendanceAction.fromValue(payload.type);
      if (action == null) {
        return QrAttendanceResult.invalidPayload();
      }

        final scanTimestamp = DateTime.now().millisecondsSinceEpoch;
        final scanTime = DateTime.fromMillisecondsSinceEpoch(scanTimestamp);
        final organizationSnapshot = await _firestore
          .collection('organizations')
          .doc(payload.organizationId)
          .get();
        final organizationData = organizationSnapshot.data();
        final settingsRaw = organizationData == null
            ? null
            : organizationData['settings'];
        final settings = settingsRaw is Map<String, dynamic>
            ? settingsRaw
            : null;
        final policy = attendancePolicyFromSettings(settings, scanTime);
        final attendanceStatus = classifyAttendanceScanStatus(policy, scanTime);

        // Geo-fencing validation
        double? scannerLat, scannerLng, distanceFromOrg;
        final showOfficeRadius = settings?['showOfficeRadius'] ?? false;
        final strictMode = settings?['strictMode'] ?? false;
        if (showOfficeRadius && strictMode) {
          final location = settings?['location'];
          if (location is Map<String, dynamic>) {
            final orgLat = (location['lat'] as num?)?.toDouble() ?? 0.0;
            final orgLng = (location['lng'] as num?)?.toDouble() ?? 0.0;
            final allowedRadius = (settings?['allowedRadius'] as num?)?.toInt() ?? 100;

            final locationService = LocationService();
            final scannerLocation = await locationService.getCurrentLocation();
            if (scannerLocation == null) {
              return QrAttendanceResult.error('Unable to get scanner location.');
            }

            scannerLat = scannerLocation['lat'];
            scannerLng = scannerLocation['lng'];
            distanceFromOrg = Geolocator.distanceBetween(
              scannerLat!,
              scannerLng!,
              orgLat,
              orgLng,
            );

            if (distanceFromOrg > allowedRadius) {
              return QrAttendanceResult.error('Scanner is outside allowed area.');
            }
          }
        }

        final nextStatus = action == QrAttendanceAction.signIn
          ? (attendanceStatus == AttendanceScanStatus.late
              ? 'Late'
              : 'Present')
          : 'Absent';

      final attendanceRef = _firestore
          .collection('attendance')
          .doc(payload.attendanceDocumentId());
      final userRef = _firestore.collection('users').doc(payload.userId);

      return _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(attendanceRef);
        if (snapshot.exists) {
          return QrAttendanceResult.duplicate();
        }

        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          return QrAttendanceResult.invalidPayload();
        }

        final userData = userSnapshot.data() as Map<String, dynamic>?;
        final userOrgId = (userData?['orgId'] ?? '').toString().trim();
        if (userOrgId.isEmpty || userOrgId != payload.organizationId.trim()) {
          return QrAttendanceResult.invalidOrganization();
        }

        transaction.set(attendanceRef, {
          'userId': payload.userId,
          'organizationId': payload.organizationId,
          'type': action.value,
          'scanTimestamp': scanTimestamp,
          'attendanceStatus': attendanceStatus,
          'timestamp': FieldValue.serverTimestamp(),
          if (payload.lat != null) 'userLat': payload.lat,
          if (payload.lng != null) 'userLng': payload.lng,
          if (scannerLat != null) 'scannerLat': scannerLat,
          if (scannerLng != null) 'scannerLng': scannerLng,
          if (distanceFromOrg != null) 'distanceFromOrg': distanceFromOrg,
        });

        transaction.update(userRef, {
          'status': nextStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return QrAttendanceResult.success(payload);
      });
    } on FirebaseException catch (e) {
      debugPrint(
        '[QrAttendanceService.validateAndRecordAttendance] FirebaseException(${e.code}): ${e.message}',
      );
      return QrAttendanceResult.error(
        e.message ?? 'Failed to record attendance.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[QrAttendanceService.validateAndRecordAttendance] Unexpected error: $e',
      );
      debugPrint(
        '[QrAttendanceService.validateAndRecordAttendance] Stack: $stackTrace',
      );
      return QrAttendanceResult.error('Failed to record attendance.');
    }
  }
}
