class AttendancePolicy {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? lateThresholdTime;
  final int? lateThresholdMinutes;

  const AttendancePolicy({
    required this.checkInTime,
    required this.checkOutTime,
    required this.lateThresholdTime,
    required this.lateThresholdMinutes,
  });

  bool get hasAnyRule =>
      checkInTime != null || checkOutTime != null || lateThresholdTime != null;
}

class AttendanceScanStatus {
  static const String early = 'early';
  static const String onTime = 'on_time';
  static const String late = 'late';
}

AttendancePolicy attendancePolicyFromSettings(
  Map<String, dynamic>? settings,
  DateTime anchor,
) {
  final rawCheckIn = (settings?['checkInTime'] ?? '').toString();
  final rawCheckOut = (settings?['checkOutTime'] ?? '').toString();
  final rawLateThreshold = (settings?['lateThreshold'] ?? '').toString();

  return AttendancePolicy(
    checkInTime: parsePolicyTime(rawCheckIn, anchor),
    checkOutTime: parsePolicyTime(rawCheckOut, anchor),
    lateThresholdTime: parsePolicyTime(rawLateThreshold, anchor),
    lateThresholdMinutes: parseLateThresholdMinutes(rawLateThreshold),
  );
}

int? parseLateThresholdMinutes(String rawThreshold) {
  final input = rawThreshold.trim();
  if (input.isEmpty) {
    return null;
  }

  // Supports direct minutes, e.g. "15".
  final directMinutes = int.tryParse(input);
  if (directMinutes != null && directMinutes >= 0) {
    return directMinutes;
  }

  // Supports duration-like HH:mm, e.g. "00:15" or "1:30".
  final durationMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(input);
  if (durationMatch == null) {
    return null;
  }

  final hours = int.tryParse(durationMatch.group(1) ?? '');
  final minutes = int.tryParse(durationMatch.group(2) ?? '');
  if (hours == null || minutes == null || minutes < 0 || minutes > 59) {
    return null;
  }

  return (hours * 60) + minutes;
}

DateTime? parsePolicyTime(String rawTime, DateTime anchor) {
  final input = rawTime.trim();
  if (input.isEmpty) {
    return null;
  }

  final amPmMatch = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$',
  ).firstMatch(input);
  if (amPmMatch != null) {
    final hourPart = int.tryParse(amPmMatch.group(1) ?? '');
    final minutePart = int.tryParse(amPmMatch.group(2) ?? '');
    final period = (amPmMatch.group(3) ?? '').toLowerCase();

    if (hourPart == null || minutePart == null) {
      return null;
    }

    if (hourPart < 1 || hourPart > 12 || minutePart < 0 || minutePart > 59) {
      return null;
    }

    int hour = hourPart % 12;
    if (period == 'pm') {
      hour += 12;
    }

    return DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
      hour,
      minutePart,
    );
  }

  final twentyFourMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(input);
  if (twentyFourMatch != null) {
    final hour = int.tryParse(twentyFourMatch.group(1) ?? '');
    final minute = int.tryParse(twentyFourMatch.group(2) ?? '');

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return DateTime(anchor.year, anchor.month, anchor.day, hour, minute);
  }

  return null;
}

bool isSignInOpen(AttendancePolicy policy, DateTime now) {
  if (policy.checkInTime == null) {
    return true;
  }

  final signInOpenTime = policy.checkInTime!.subtract(const Duration(minutes: 15));
  return !now.isBefore(signInOpenTime);
}

bool isSignOutOpen(AttendancePolicy policy, DateTime now) {
  if (policy.checkOutTime == null) {
    return true;
  }

  final signOutOpenTime =
      policy.checkOutTime!.subtract(const Duration(minutes: 5));
  return !now.isBefore(signOutOpenTime);
}

bool isLateByPolicy(AttendancePolicy policy, DateTime timestamp) {
  final lateCutoff = resolveLateCutoff(policy);
  if (policy.checkInTime == null || lateCutoff == null) {
    return false;
  }

  return !timestamp.isBefore(policy.checkInTime!) &&
      !timestamp.isAfter(lateCutoff);
}

String classifyAttendanceScanStatus(AttendancePolicy policy, DateTime scanTime) {
  final checkInTime = policy.checkInTime;
  final lateCutoff = resolveLateCutoff(policy);

  if (checkInTime == null || lateCutoff == null) {
    return AttendanceScanStatus.onTime;
  }

  if (scanTime.isBefore(checkInTime)) {
    return AttendanceScanStatus.early;
  }

  if (!scanTime.isAfter(lateCutoff)) {
    return AttendanceScanStatus.onTime;
  }

  return AttendanceScanStatus.late;
}

DateTime? resolveLateCutoff(AttendancePolicy policy) {
  final checkInTime = policy.checkInTime;
  if (checkInTime == null) {
    return null;
  }

  // Primary rule: cutoff = checkInTime + lateThreshold (minutes/duration).
  if (policy.lateThresholdMinutes != null) {
    return checkInTime.add(Duration(minutes: policy.lateThresholdMinutes!));
  }

  // Backward compatibility: if lateThreshold was saved as a concrete clock time.
  if (policy.lateThresholdTime != null) {
    return policy.lateThresholdTime;
  }

  return null;
}
