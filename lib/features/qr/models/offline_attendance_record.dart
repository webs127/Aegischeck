class OfflineAttendanceRecord {
  final String id; // Unique identifier for the record
  final String userId;
  final String organizationId;
  final String type; // 'sign_in' or 'sign_out'
  final int qrTimestamp; // Timestamp from QR payload
  final int scanTimestamp; // Timestamp when scanned
  bool synced; // Whether this record has been synced to Firestore
  final int createdAt; // Local creation timestamp
  String? syncError; // Error message if sync failed

  OfflineAttendanceRecord({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.type,
    required this.qrTimestamp,
    required this.scanTimestamp,
    this.synced = false,
    int? createdAt,
    this.syncError,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// Convert to map for Firestore upload
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'type': type,
      'timestamp': scanTimestamp, // Use scan timestamp as the official time
      'qrTimestamp': qrTimestamp,
      'createdAt': createdAt,
    };
  }

  /// Create from map (useful for local storage)
  factory OfflineAttendanceRecord.fromMap(Map<String, dynamic> map) {
    return OfflineAttendanceRecord(
      id: map['id'] as String,
      userId: map['userId'] as String,
      organizationId: map['organizationId'] as String,
      type: map['type'] as String,
      qrTimestamp: map['qrTimestamp'] as int,
      scanTimestamp: map['scanTimestamp'] as int,
      synced: map['synced'] as bool? ?? false,
      createdAt: map['createdAt'] as int?,
      syncError: map['syncError'] as String?,
    );
  }

  /// Convert to map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'type': type,
      'qrTimestamp': qrTimestamp,
      'scanTimestamp': scanTimestamp,
      'synced': synced,
      'createdAt': createdAt,
      'syncError': syncError,
    };
  }

  @override
  String toString() {
    return 'OfflineAttendanceRecord(id: $id, userId: $userId, orgId: $organizationId, type: $type, synced: $synced)';
  }
}
