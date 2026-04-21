import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/offline_attendance_record.dart';
import '../repositories/offline_attendance_repository.dart';
import 'attendance_policy_utils.dart';
import 'connectivity_service.dart';

abstract class OfflineAttendanceSyncService {
  /// Start monitoring connectivity and auto-syncing
  void startAutoSync();

  /// Stop monitoring connectivity
  void stopAutoSync();

  /// Manually sync all unsynced records
  Future<void> syncNow();

  /// Get stream of sync status updates
  Stream<SyncStatusUpdate> get syncStatusStream;
}

class SyncStatusUpdate {
  final int totalRecords;
  final int syncedRecords;
  final int failedRecords;
  final bool isSyncing;
  final String? lastError;

  SyncStatusUpdate({
    required this.totalRecords,
    required this.syncedRecords,
    required this.failedRecords,
    required this.isSyncing,
    this.lastError,
  });
}

class OfflineAttendanceSyncServiceImpl
    extends ChangeNotifier
    implements OfflineAttendanceSyncService {
  final FirebaseFirestore _firestore;
  final OfflineAttendanceRepository _repository;
  final ConnectivityService _connectivityService;

  bool _isSyncing = false;
  bool _isMonitoring = false;
  String? _lastError;

  OfflineAttendanceSyncServiceImpl(
    this._firestore,
    this._repository,
    this._connectivityService,
  );

  @override
  void startAutoSync() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    // Listen to connectivity changes and sync when online
    _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncNow();
      }
    });
  }

  @override
  void stopAutoSync() {
    _isMonitoring = false;
  }

  @override
  Future<void> syncNow() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final unsyncedRecords = await _repository.getUnsyncedRecords();

      for (final record in unsyncedRecords) {
        if (record.syncError != null &&
            _looksLikeNetworkFailure(record.syncError!)) {
          await _repository.clearSyncError(record.id);
        }
      }

      final retryRecords = await _repository.getUnsyncedRecords();

      if (retryRecords.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return;
      }

      // Batch sync with retries
      for (final record in retryRecords) {
        await _syncRecord(record);
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync a single record to Firestore
  Future<void> _syncRecord(OfflineAttendanceRecord record) async {
    try {
      // Check if document already exists in Firestore (duplicate prevention)
      final attendanceRef = _firestore
          .collection('attendance')
          .doc('${record.userId}_${_getDateString(record.scanTimestamp)}_${record.type}');

      final exists = await attendanceRef.get();
      if (exists.exists) {
        // Document already exists, mark as synced
        await _repository.markAsSynced(record.id);
        return;
      }

      // Upload to Firestore with server timestamp
      final actionTime = DateTime.fromMillisecondsSinceEpoch(
        record.scanTimestamp,
      );
      final policy = await _loadAttendancePolicy(
        record.organizationId,
        actionTime,
      );
      final attendanceStatus = classifyAttendanceScanStatus(policy, actionTime);

      await attendanceRef.set({
        'userId': record.userId,
        'organizationId': record.organizationId,
        'type': record.type,
        'scanTimestamp': record.scanTimestamp,
        'attendanceStatus': attendanceStatus,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Also update user status in transaction
      final userRef = _firestore.collection('users').doc(record.userId);
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final newStatus = record.type == 'sign_in'
              ? (attendanceStatus == AttendanceScanStatus.late
                  ? 'Late'
                  : 'Present')
              : 'Absent';
          transaction.update(userRef, {'status': newStatus});
        }
      });

      // Mark as synced
      await _repository.markAsSynced(record.id);
    } catch (e) {
      _lastError = e.toString();

      if (_isTransientSyncError(e)) {
        debugPrint(
          '[OfflineAttendanceSyncService] Transient sync error for ${record.id}: $e',
        );
        return;
      }

      // Mark as failed only for non-transient errors so the UI can surface
      // actual data or permission problems.
      await _repository.markAsSyncFailed(record.id, e.toString());
    }
  }

  /// Get stream of sync updates
  @override
  Stream<SyncStatusUpdate> get syncStatusStream async* {
    while (_isMonitoring) {
      final allRecords = await _repository.getAllRecords();
      final syncedRecords = allRecords.where((r) => r.synced).length;
      final failedRecords =
          allRecords.where((r) => !r.synced && r.syncError != null).length;

      yield SyncStatusUpdate(
        totalRecords: allRecords.length,
        syncedRecords: syncedRecords,
        failedRecords: failedRecords,
        isSyncing: _isSyncing,
        lastError: _lastError,
      );

      // Update every 2 seconds
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// Helper to get date string from timestamp (YYYYMMDD)
  String _getDateString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  bool _isTransientSyncError(Object error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'network-request-failed' ||
          error.code == 'deadline-exceeded' ||
          error.message != null && _looksLikeNetworkFailure(error.message!);
    }

    if (error is SocketException) {
      return true;
    }

    return _looksLikeNetworkFailure(error.toString());
  }

  bool _looksLikeNetworkFailure(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('service is currently unavailable') ||
        normalized.contains('unable to resolve host') ||
        normalized.contains('no address associated with hostname') ||
        normalized.contains('socketexception') ||
        normalized.contains('network') ||
        normalized.contains('timeout') ||
        normalized.contains('unavailable');
  }

  Future<AttendancePolicy> _loadAttendancePolicy(
    String organizationId,
    DateTime anchor,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .get();
      final data = snapshot.data();
        final settingsRaw = data == null ? null : data['settings'];
        final settings = settingsRaw is Map<String, dynamic>
          ? settingsRaw
          : null;
      return attendancePolicyFromSettings(settings, anchor);
    } catch (_) {
      return attendancePolicyFromSettings(null, anchor);
    }
  }
}
