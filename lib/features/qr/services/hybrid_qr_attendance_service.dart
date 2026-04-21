import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offline_attendance_record.dart';
import '../models/qr_attendance_payload.dart';
import '../models/qr_attendance_result.dart';
import '../repositories/offline_attendance_repository.dart';
import 'connectivity_service.dart';
import 'qr_attendance_service.dart';

/// Wraps QrAttendanceService with offline capability
/// Tries online first, falls back to offline storage if no connectivity
class HybridQrAttendanceService implements QrAttendanceService {
  final QrAttendanceService _onlineService;
  final OfflineAttendanceRepository _offlineRepository;
  final ConnectivityService _connectivityService;

  HybridQrAttendanceService(
    this._onlineService,
    this._offlineRepository,
    this._connectivityService,
  );

  @override
  Future<QrAttendanceResult> validateAndRecordAttendance({
    required String rawQrPayload,
    required String scannerUserId,
    required String scannerOrganizationId,
    required String scannerRole,
  }) async {
    // Check connectivity
    final isOnline = await _connectivityService.isOnline();

    if (isOnline) {
      // Try online first
      try {
        final result = await _onlineService.validateAndRecordAttendance(
          rawQrPayload: rawQrPayload,
          scannerUserId: scannerUserId,
          scannerOrganizationId: scannerOrganizationId,
          scannerRole: scannerRole,
        );

        if (_shouldFallBackToOffline(result)) {
          return _saveOfflineAttendance(
            rawQrPayload: rawQrPayload,
            scannerUserId: scannerUserId,
            scannerOrganizationId: scannerOrganizationId,
            scannerRole: scannerRole,
          );
        }

        return result;
      } on FirebaseException catch (e) {
        if (_isConnectivityError(e)) {
          return _saveOfflineAttendance(
            rawQrPayload: rawQrPayload,
            scannerUserId: scannerUserId,
            scannerOrganizationId: scannerOrganizationId,
            scannerRole: scannerRole,
          );
        }

        return QrAttendanceResult.error('Failed to save attendance: ${e.message ?? e.code}');
      } catch (e) {
        if (_isConnectivityMessage(e.toString())) {
          return _saveOfflineAttendance(
            rawQrPayload: rawQrPayload,
            scannerUserId: scannerUserId,
            scannerOrganizationId: scannerOrganizationId,
            scannerRole: scannerRole,
          );
        }

        return QrAttendanceResult.error('Failed to save attendance: $e');
      }
    }

    // No connectivity - save offline
    return _saveOfflineAttendance(
      rawQrPayload: rawQrPayload,
      scannerUserId: scannerUserId,
      scannerOrganizationId: scannerOrganizationId,
      scannerRole: scannerRole,
    );
  }

  /// Validate and save attendance record offline
  Future<QrAttendanceResult> _saveOfflineAttendance({
    required String rawQrPayload,
    required String scannerUserId,
    required String scannerOrganizationId,
    required String scannerRole,
  }) async {
    try {
      // 1. Validate scanner authorization
      if (scannerUserId.trim().isEmpty ||
          scannerOrganizationId.trim().isEmpty) {
        return QrAttendanceResult.unauthorized();
      }

      final normalizedRole = scannerRole.trim().toLowerCase();
      final hasAccess =
          normalizedRole == 'admin' || normalizedRole.contains('admin');
      if (!hasAccess) {
        return QrAttendanceResult.unauthorized();
      }

      // 2. Parse QR payload
      final payload = QrAttendancePayload.tryParse(rawQrPayload);
      if (payload == null) {
        return QrAttendanceResult.invalidPayload();
      }

      // 3. Check expiry with clock skew tolerance
      if (payload.isExpired()) {
        return QrAttendanceResult.expired();
      }

      // 4. Verify organization match
      if (payload.organizationId.trim() !=
          scannerOrganizationId.trim()) {
        return QrAttendanceResult.invalidOrganization();
      }

      // 5. Check for local duplicates (same user, same type, same day)
      final now = DateTime.now();
      final dateString =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final isDuplicate =
          await _offlineRepository.recordExists(payload.userId, payload.type, dateString);
      if (isDuplicate) {
        return QrAttendanceResult.duplicate();
      }

      // 6. Create offline record
      final scanTimestamp = DateTime.now().millisecondsSinceEpoch;
      const uuid = Uuid();
      final recordId = uuid.v4();

      final record = OfflineAttendanceRecord(
        id: recordId,
        userId: payload.userId,
        organizationId: payload.organizationId,
        type: payload.type,
        qrTimestamp: payload.timestamp,
        scanTimestamp: scanTimestamp,
        synced: false,
      );

      // 7. Save offline
      await _offlineRepository.saveRecord(record);

      return QrAttendanceResult(
        outcome: QrAttendanceOutcome.success,
        message: 'Attendance saved offline. Will sync when connected.',
      );
    } catch (e) {
      return QrAttendanceResult.error('Offline save failed: $e');
    }
  }

  bool _shouldFallBackToOffline(QrAttendanceResult result) {
    if (result.outcome != QrAttendanceOutcome.error) {
      return false;
    }

    return _isConnectivityMessage(result.message);
  }

  bool _isConnectivityError(FirebaseException error) {
    return error.code == 'unavailable' ||
        error.code == 'network-request-failed' ||
        error.message != null && _isConnectivityMessage(error.message!);
  }

  bool _isConnectivityMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('service is currently unavailable') ||
        normalized.contains('unable to resolve host') ||
        normalized.contains('no address associated with hostname') ||
        normalized.contains('network') ||
        normalized.contains('unavailable');
  }
}
