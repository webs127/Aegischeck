import 'package:flutter_test/flutter_test.dart';

import 'package:aegischeck/features/qr/models/qr_attendance_action.dart';
import 'package:aegischeck/features/qr/models/qr_attendance_payload.dart';

void main() {
  test('qr payload round-trips through json', () {
    const payload = QrAttendancePayload(
      userId: 'user-123',
      organizationId: 'org-456',
      type: 'sign_in',
      timestamp: 1710000000000,
    );

    final parsed = QrAttendancePayload.tryParse(payload.toRawJson());

    expect(parsed, isNotNull);
    expect(parsed!.userId, 'user-123');
    expect(parsed.organizationId, 'org-456');
    expect(parsed.type, QrAttendanceAction.signIn.value);
    expect(parsed.timestamp, 1710000000000);
  });

  test('qr payload expires after thirty seconds', () {
    final payload = QrAttendancePayload(
      userId: 'user-123',
      organizationId: 'org-456',
      type: 'sign_out',
      timestamp: DateTime.now().subtract(const Duration(seconds: 95)).millisecondsSinceEpoch,
    );

    expect(payload.isExpired(), isTrue);
  });

  test('qr payload tolerates small clock skew', () {
    final payload = QrAttendancePayload(
      userId: 'user-123',
      organizationId: 'org-456',
      type: 'sign_in',
      timestamp: DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch,
    );

    expect(payload.isExpired(), isFalse);
  });

  test('attendance document id includes day and action', () {
    const payload = QrAttendancePayload(
      userId: 'user-123',
      organizationId: 'org-456',
      type: 'sign_out',
      timestamp: 1710000000000,
    );

    expect(payload.attendanceDocumentId(DateTime(2026, 4, 14)), 'user-123_20260414_sign_out');
  });
}
