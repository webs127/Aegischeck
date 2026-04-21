import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  init() {
    Future.delayed(Duration(seconds: 2), nextPage);
  }

  nextPage() {
    context.pushNamed(RouteConstants.onboarding);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, size: 32, color: ColorManager.primary),
            Text(
              "Aegis Check",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
