import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/landing/viewmodels/landing_viewmodel.dart';
import 'package:aegischeck/features/landing/widgets/appbar.dart';
import 'package:aegischeck/features/landing/widgets/sidebar_listtile.dart';
import 'package:aegischeck/features/landing/widgets/sidebar_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Row(
          children: [
            context.watch<LandingViewModel>().showSidebar
                ? SizedBox(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorManager.grey),
                          ),
                          width: 200,
                          height: size.height,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                SidebarTitle(),
                                ...List.generate(
                                  context.read<LandingViewModel>().length,
                                  (i) => SidebarListTile(
                                    selected: context
                                        .read<LandingViewModel>()
                                        .isSelected(i),
                                    onPressed: () {
                                      context.read<LandingViewModel>().onSelect(
                                        i,
                                      );
                                    },
                                    text: context
                                        .read<LandingViewModel>()
                                        .sidebartexts[i],
                                  ),
                                ),
                                context.read<LandingViewModel>().isSettings()
                                    ? Column(
                                        children: List.generate(
                                          context
                                              .read<LandingViewModel>()
                                              .subLength,
                                          (i) => SidebarListTile(
                                            selected: context
                                                .read<LandingViewModel>()
                                                .isSubSelected(i),
                                            onPressed: () {
                                              context
                                                  .read<LandingViewModel>()
                                                  .onSubChanged(i);
                                            },
                                            fontSize: 12,
                                            showIcon: false,
                                            text: context
                                                .read<LandingViewModel>()
                                                .settingSubtexts[i],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            Expanded(
              child: Align(
                alignment: AlignmentGeometry.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //App bar 
                      CustomAppBar(),
                      context.watch<LandingViewModel>().isSettings()
                          ? context.watch<LandingViewModel>().subview
                          : context.watch<LandingViewModel>().view,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

