
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/views/admin_login.dart';
import 'package:aegischeck/features/auth/widgets/onboarding_details_widget.dart';
import 'package:flutter/material.dart';

class ReusableSetupWidget extends StatelessWidget {
  final String headerTextLeft;
  final String headertextRight;
  final Color headerRightColor;
  final List<OnboardingSetupObject> onboardingSetupObject;
  final String footer;
  final String subFooter;
  final Widget? right;
  const ReusableSetupWidget({
    super.key,
    required this.headerTextLeft,
    required this.headertextRight,
    required this.headerRightColor,
    required this.onboardingSetupObject,
    required this.footer,
    required this.subFooter,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.qr_code, color: ColorManager.white),
                    Text(
                      "AegisCheck",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.white,
                      ),
                    ),
                  ],
                ),
                Card(
                  color: Colors.transparent.withValues(alpha: .05),
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.grey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 28,
                    ),
                    child: Column(
                      spacing: 20,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              headerTextLeft,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: ColorManager.white,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: headerRightColor),
                                borderRadius: BorderRadius.circular(24),
                                color: headerRightColor.withValues(alpha: .2),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: SizedBox(
                                child: Text(
                                  headertextRight,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: headerRightColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1),
                        ...List.generate(
                          onboardingSetupObject.length,
                          (i) => OnboardingDetailsWidget(
                            length: onboardingSetupObject.length,
                            index: i,
                            onboardingSetupObject: onboardingSetupObject[i],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      footer,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.white,
                      ),
                    ),
                    Text(
                      subFooter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(color: ColorManager.white),
            child: right ?? SizedBox(),
          ),
        ),
      ],
    );
  }
}
