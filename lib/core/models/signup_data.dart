class SignUpData {
  final String email;
  final String password;
  final String username;
  final String orgName;
  final List<String> workDays;
  final String useCase;
  final int orgSize;
  final String orgCode;

  SignUpData({
    required this.email,
    required this.password,
    required this.username,
    required this.orgName,
    required this.workDays,
    required this.useCase,
    required this.orgSize,
    required this.orgCode,
  });
}

class SignUpWithOrgCodeData {
  final String email;
  final String password;
  final String fullname;
  final String orgCode;
  final String role;
  final String department;
  final String status;

  SignUpWithOrgCodeData({
    required this.email,
    required this.password,
    required this.fullname,
    required this.orgCode,
    required this.role,
    required this.department,
    required this.status,
  });
}
