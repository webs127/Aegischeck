import 'dart:convert';

import 'qr_attendance_action.dart';

class QrAttendancePayload {
  static const int expiryWindowMs = 30000;
  static const int clockSkewToleranceMs = 60000;

  final String userId;
  final String organizationId;
  final String type;
  final int timestamp;

  const QrAttendancePayload({
    required this.userId,
    required this.organizationId,
    required this.type,
    required this.timestamp,
  });

  QrAttendanceAction? get action => QrAttendanceAction.fromValue(type);

  bool get isValidAction => action != null;

  bool isExpired([DateTime? now]) {
    final currentTimestamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final ageMs = currentTimestamp - timestamp;

    if (ageMs < -clockSkewToleranceMs) {
      return true;
    }

    return ageMs > expiryWindowMs + clockSkewToleranceMs;
  }

  String dayKey([DateTime? now]) {
    final date = now ?? DateTime.now();
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  String attendanceDocumentId([DateTime? now]) {
    return '${userId}_${dayKey(now)}_$type';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'type': type,
      'timestamp': timestamp,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory QrAttendancePayload.fromJson(Map<String, dynamic> json) {
    return QrAttendancePayload(
      userId: (json['userId'] ?? '').toString().trim(),
      organizationId: (json['organizationId'] ?? '').toString().trim(),
      type: (json['type'] ?? '').toString().trim(),
      timestamp: int.tryParse(json['timestamp'].toString()) ?? 0,
    );
  }

  static QrAttendancePayload? tryParse(String rawPayload) {
    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final payload = QrAttendancePayload.fromJson(decoded);
      if (payload.userId.isEmpty ||
          payload.organizationId.isEmpty ||
          payload.type.isEmpty ||
          payload.timestamp <= 0 ||
          !payload.isValidAction) {
        return null;
      }
      return payload;
    } catch (_) {
      return null;
    }
  }
}
