import 'package:aegischeck/core/constants/image_constants.dart';
import 'package:aegischeck/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingViewModel with ChangeNotifier {
  late PageController pageController;
  int currentIndex = 0;
  int get length => _onboardingObjects.length;

  OnboardingViewModel() {
    pageController = PageController();
  }

  final List<OnboardingObject> _onboardingObjects = [
    OnboardingObject(
      imagePath: ImageConstants.attendance,
      textHeader: "Smart Attendance",
      textDescription:
          "Track attendance quickly using secure QR codes. Employess or students simply present a personal code for fast, reliable entry.",
    ),
    OnboardingObject(
      imagePath: ImageConstants.checkin,
      textHeader: "Fast Check-In",
      textDescription:
          "Employees show their QR code and get scanned instantly at the entrance.",
    ),
    OnboardingObject(
      imagePath: ImageConstants.realtime,
      textHeader: "Real-time Monitoring",
      textDescription:
          "Admins can monitor attendance and generate reports instantly.",
    ),
  ];

  OnboardingObject get onboardingObject => _onboardingObjects[currentIndex];

  onPageChanged(int value) {
    currentIndex = value;
    notifyListeners();
  }

  bool check() {
    if (currentIndex == _onboardingObjects.length - 1) {
      return true;
    }
    return false;
  }

  nextPage() {
    pageController.nextPage(duration: Durations.medium4, curve: Curves.ease);
  }

  nextScreen(BuildContext context) {
    context.pushNamed(RouteConstants.mobileAuthWrapper);
  }
}

class OnboardingObject {
  final String imagePath;
  final String textHeader;
  final String textDescription;

  OnboardingObject({
    required this.imagePath,
    required this.textHeader,
    required this.textDescription,
  });
}
