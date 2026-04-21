import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/views/admin_onboarding_view_components.dart';
import 'package:aegischeck/features/auth/widgets/reusable_setup_widget.dart';
import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary1,
      body: ReusableSetupWidget(
        headerTextLeft: "live Attendance Overview",
        headertextRight: "live Feed Active",
        headerRightColor: Colors.green,
        right: AdminLoginView(),
        onboardingSetupObject: [
          OnboardingSetupObject(
            icon: Icons.person,
            left: "Present Today",
            right: "342",
          ),
          OnboardingSetupObject(
            icon: Icons.timelapse_sharp,
            left: "Late Arrivals",
            right: "18",
          ),
          OnboardingSetupObject(icon: Icons.person, left: "Absent", right: "5"),
        ],
        footer:
            "\"AegisCheck has completely tranformed how we manage staff sttendance across all our coporate facilities.\"",
        subFooter: "Shittu Divinedavid Abolanle, Founder",
      ),
    );
  }
}


class OnboardingSetupObject {
  final IconData icon;
  final String left;
  final String? right;

  OnboardingSetupObject({
    required this.icon,
    required this.left,
    this.right,
  });
}
