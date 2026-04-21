
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/views/admin_login.dart';
import 'package:flutter/material.dart';

class OnboardingDetailsWidget extends StatelessWidget {
  final int length;
  final int index;
  final OnboardingSetupObject onboardingSetupObject;
  const OnboardingDetailsWidget({
    super.key,
    required this.length,
    required this.onboardingSetupObject,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(onboardingSetupObject.icon, color: ColorManager.white),
                Text(
                  onboardingSetupObject.left,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.white,
                  ),
                ),
              ],
            ),
            onboardingSetupObject.right ==  null ? SizedBox() : Text(
              onboardingSetupObject.right!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorManager.white,
              ),
            ),
          ],
        ),
        index == length - 1 ? SizedBox() : Divider(thickness: .5),
      ],
    );
  }
}