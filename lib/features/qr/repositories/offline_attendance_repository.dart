import 'package:hive/hive.dart';

import '../models/offline_attendance_record.dart';

abstract class OfflineAttendanceRepository {
  /// Save a single offline attendance record
  Future<void> saveRecord(OfflineAttendanceRecord record);

  /// Get all unsynced records
  Future<List<OfflineAttendanceRecord>> getUnsyncedRecords();

  /// Mark a record as synced
  Future<void> markAsSynced(String recordId);

  /// Mark a record as failed to sync with error message
  Future<void> markAsSyncFailed(String recordId, String errorMessage);

  /// Clear a record's sync error and return it to pending retry state
  Future<void> clearSyncError(String recordId);

  /// Delete a record
  Future<void> deleteRecord(String recordId);

  /// Get all records
  Future<List<OfflineAttendanceRecord>> getAllRecords();

  /// Check if a record already exists locally (for duplicate prevention)
  Future<bool> recordExists(
    String userId,
    String type,
    String datString, // Format: YYYYMMDD
  );

  /// Clear all synced records (optional cleanup)
  Future<void> clearSyncedRecords();
}

class OfflineAttendanceRepositoryImpl implements OfflineAttendanceRepository {
  static const String _boxName = 'offline_attendance';
  Box<Map>? _box;

  /// Initialize the local database
  Future<void> initialize() async {
    _box ??= await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get box {
    if (_box == null) {
      throw StateError(
        'OfflineAttendanceRepository not initialized. Call initialize() first.',
      );
    }
    return _box!;
  }

  @override
  Future<void> saveRecord(OfflineAttendanceRecord record) async {
    await initialize();
    await box.put(record.id, record.toMap());
  }

  @override
  Future<List<OfflineAttendanceRecord>> getUnsyncedRecords() async {
    await initialize();
    return box.values
        .whereType<Map>()
        .map((record) => OfflineAttendanceRecord.fromMap(
              Map<String, dynamic>.from(record),
            ))
        .where((record) => !record.synced)
        .toList();
  }

  @override
  Future<void> markAsSynced(String recordId) async {
    await initialize();
    final rawRecord = box.get(recordId);
    if (rawRecord != null) {
      final record = OfflineAttendanceRecord.fromMap(
        Map<String, dynamic>.from(rawRecord),
      );
      record.synced = true;
      record.syncError = null;
      await box.put(recordId, record.toMap());
    }
  }

  @override
  Future<void> markAsSyncFailed(String recordId, String errorMessage) async {
    await initialize();
    final rawRecord = box.get(recordId);
    if (rawRecord != null) {
      final record = OfflineAttendanceRecord.fromMap(
        Map<String, dynamic>.from(rawRecord),
      );
      record.synced = false;
      record.syncError = errorMessage;
      await box.put(recordId, record.toMap());
    }
  }

  @override
  Future<void> clearSyncError(String recordId) async {
    await initialize();
    final rawRecord = box.get(recordId);
    if (rawRecord != null) {
      final record = OfflineAttendanceRecord.fromMap(
        Map<String, dynamic>.from(rawRecord),
      );
      record.syncError = null;
      record.synced = false;
      await box.put(recordId, record.toMap());
    }
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    await initialize();
    await box.delete(recordId);
  }

  @override
  Future<List<OfflineAttendanceRecord>> getAllRecords() async {
    await initialize();
    return box.values
        .whereType<Map>()
        .map((record) => OfflineAttendanceRecord.fromMap(
              Map<String, dynamic>.from(record),
            ))
        .toList();
  }

  @override
  Future<bool> recordExists(
    String userId,
    String type,
    String dateString, // Format: YYYYMMDD
  ) async {
    await initialize();
    return box.values.whereType<Map>().any((record) {
      final localRecord = OfflineAttendanceRecord.fromMap(
        Map<String, dynamic>.from(record),
      );
      return localRecord.userId == userId &&
          localRecord.type == type &&
          _getDateString(localRecord.scanTimestamp) == dateString;
    });
  }

  @override
  Future<void> clearSyncedRecords() async {
    await initialize();
    final keysToDelete = <String>[];
    for (final key in box.keys) {
      final rawRecord = box.get(key);
      if (rawRecord == null) {
        continue;
      }

      final localRecord = OfflineAttendanceRecord.fromMap(
        Map<String, dynamic>.from(rawRecord),
      );
      if (localRecord.synced) {
        keysToDelete.add(key.toString());
      }
    }
    await box.deleteAll(keysToDelete);
  }

  /// Helper to get date string from timestamp (YYYYMMDD)
  String _getDateString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  /// Close the box (useful for cleanup)
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
