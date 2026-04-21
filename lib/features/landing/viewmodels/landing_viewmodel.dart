import 'package:aegischeck/features/dashboard/views/dashboard.dart';
import 'package:aegischeck/features/employees/views/employees.dart';
import 'package:aegischeck/features/report/views/report.dart';
import 'package:aegischeck/features/settings/views/organization_profile.dart';
import 'package:aegischeck/features/settings/views/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:aegischeck/features/settings/views/attendance_policies.dart';
import 'package:aegischeck/features/settings/views/notifications.dart';
import 'package:aegischeck/features/settings/views/security_access.dart';
import 'package:flutter/material.dart';

class LandingViewModel with ChangeNotifier {
  bool showSidebar = false;
  String selected = "Dashboard";
  int get length => sidebartexts.length;

  int currentIndex = 0;

  int get viewlength => _views.length;

  final List<String> sidebartexts = [
    "Dashboard",
    "Employees",
    "Report",
    "Settings",
  ];

  Widget get view => _views[currentIndex];

  final List<Widget> _views = [
    DashboardView(),
    EmployeesScreen(),
    ReportScreen(),
    SettingsScreen(),
  ];

  switchSideBar() {
    showSidebar = !showSidebar;
    notifyListeners();
  }

  onSelect(int value) {
    currentIndex = value;
    selected = sidebartexts[value];
    notifyListeners();
  }

  bool isSelected(int index) {
    if (selected == sidebartexts[index]) {
      return true;
    }
    return false;
  }

  bool isSettings() {
    if (currentIndex == _views.length - 1) {
      return true;
    }
    return false;
  }

  //Sub Settings View Setup
  int currentSubSettingsIndex = 0;
  String selectedSub = "Organization Profile";

  final List<String> settingSubtexts = [
    "Organization Profile",
    "Attendance Policies",
    "Security Access",
    "Notifications",
  ];

  int get subLength => _subSettingsviews.length;

  final List<Widget> _subSettingsviews = [
    SettingsOrganizationProfileScreen(),
    SettingsAttendancePoliciesScreen(),
    SettingsSecurityAccessScreen(),
    SettingsNotificationsScreen(),
  ];

  Widget get subview => _subSettingsviews[currentSubSettingsIndex];

  bool isSubSelected(int index) {
    if (selectedSub == settingSubtexts[index]) {
      return true;
    }
    return false;
  }

  onSubChanged(int value) {
    currentSubSettingsIndex = value;
    selectedSub = settingSubtexts[value];
    notifyListeners();
  }
}
