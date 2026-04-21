import 'qr_attendance_payload.dart';

enum QrAttendanceOutcome {
  success,
  expired,
  invalidPayload,
  invalidOrganization,
  duplicate,
  unauthorized,
  error,
}

class QrAttendanceResult {
  final QrAttendanceOutcome outcome;
  final String message;
  final QrAttendancePayload? payload;

  const QrAttendanceResult({
    required this.outcome,
    required this.message,
    this.payload,
  });

  bool get isSuccess => outcome == QrAttendanceOutcome.success;

  factory QrAttendanceResult.success(QrAttendancePayload payload) {
    return QrAttendanceResult(
      outcome: QrAttendanceOutcome.success,
      message: 'Attendance recorded successfully.',
      payload: payload,
    );
  }

  factory QrAttendanceResult.expired() {
    return const QrAttendanceResult(
      outcome: QrAttendanceOutcome.expired,
      message: 'This QR code has expired. Ask the employee to generate a new one.',
    );
  }

  factory QrAttendanceResult.invalidPayload() {
    return const QrAttendanceResult(
      outcome: QrAttendanceOutcome.invalidPayload,
      message: 'The scanned QR payload is invalid or incomplete.',
    );
  }

  factory QrAttendanceResult.invalidOrganization() {
    return const QrAttendanceResult(
      outcome: QrAttendanceOutcome.invalidOrganization,
      message: 'This QR code belongs to another organization.',
    );
  }

  factory QrAttendanceResult.duplicate() {
    return const QrAttendanceResult(
      outcome: QrAttendanceOutcome.duplicate,
      message: 'Attendance for this action has already been recorded today.',
    );
  }

  factory QrAttendanceResult.unauthorized() {
    return const QrAttendanceResult(
      outcome: QrAttendanceOutcome.unauthorized,
      message: 'You are not authorized to record attendance on this device.',
    );
  }

  factory QrAttendanceResult.error(String message) {
    return QrAttendanceResult(
      outcome: QrAttendanceOutcome.error,
      message: message,
    );
  }
}
