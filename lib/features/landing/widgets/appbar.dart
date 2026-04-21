import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/landing/viewmodels/landing_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: ColorManager.white,
        border: Border.all(color: ColorManager.greybackground),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            //spacing: 10,
            children: [
              Selector<LandingViewModel, bool>(
                selector: (_, vm) => vm.showSidebar,
                builder: (context, showSideBar, child) => showSideBar
                    ? SizedBox()
                    : IconButton(
                        onPressed: () {
                          context.read<LandingViewModel>().switchSideBar();
                        },
                        icon: Icon(Icons.menu, color: ColorManager.black),
                      ),
              ),
              SizedBox(width: 5),

              Selector<LandingViewModel, String>(
                selector: (_, vm) => vm.selected,
                builder: (context, selected, child) => Text(
                  selected,
                  style: TextStyle(
                    color: ColorManager.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              context.watch<LandingViewModel>().isSettings()
                  ? Selector<LandingViewModel, String>(
                      selector: (_, vm) => vm.selectedSub,
                      builder: (context, selectedSub, child) => Text(
                        " / $selectedSub",
                        style: TextStyle(
                          color: ColorManager.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Row(
            spacing: 20,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Admin User",
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Organization Head",
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              InkWell(
                key: key,
                onTap: () {
                  final box =
                      key.currentContext?.findRenderObject() as RenderBox;
                  final Offset position = box.localToGlobal(
                    Offset(0, box.size.height),
                  );

                  showMenu(
                    color: ColorManager.primary1,
                    context: context,
                    position: RelativeRect.fromRect(
                      Rect.fromPoints(
                        position,
                        position + Offset(box.size.width, 0),
                      ),
                      Offset(0, 0) & MediaQuery.of(context).size,
                    ),
                    items: [
                      PopupMenuItem(
                        onTap: () {
                          context.read<AuthViewModel>().logout();
                        },
                        child: Row(
                          spacing: 10,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: ColorManager.white,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: ColorManager.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                child: CircleAvatar(
                  backgroundColor: ColorManager.primary1,
                  child: Icon(Icons.person, color: ColorManager.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
