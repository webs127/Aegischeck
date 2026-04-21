import '../models/qr_attendance_result.dart';

abstract class QrAttendanceService {
  Future<QrAttendanceResult> validateAndRecordAttendance({
    required String rawQrPayload,
    required String scannerUserId,
    required String scannerOrganizationId,
    required String scannerRole,
  });
}
