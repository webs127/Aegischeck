import 'package:aegischeck/features/auth/views/auth_gate.dart';
import 'package:aegischeck/features/splash/views/splash.dart';
import 'package:flutter/material.dart';
import 'platform_checker.dart';

class PlatformAdaptiveHome extends StatelessWidget {
  const PlatformAdaptiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isWeb) {
      return Scaffold();
    } else if (PlatformHelper.isDesktop) {
      return AuthGate();
    } else {
      return SplashScreen();
    }
  }
}
