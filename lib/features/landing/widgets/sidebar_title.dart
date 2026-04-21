
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/landing/viewmodels/landing_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SidebarTitle extends StatelessWidget {
  const SidebarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<LandingViewModel>().switchSideBar();
      },
      child: SizedBox(
        height: 60,
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, color: ColorManager.primary1),
            Text(
              "AegisCheck",
              style: TextStyle(
                color: ColorManager.primary1,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
