import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/dashboard/views/dashboard.dart';
import 'package:aegischeck/features/employees/viewmodels/employees_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTabs extends StatelessWidget {
  const CustomTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DashboardTabObject> tabs = [
      DashboardTabObject(
        icon: Icons.person,
        title: "Present Today",
        color: Colors.green,
      ),
      DashboardTabObject(
        icon: Icons.access_time,
        title: "Late Empolyees",
        color: Colors.orange,
      ),
      DashboardTabObject(
        icon: Icons.dangerous,
        title: "Absent",
        color: Colors.red,
      ),
      DashboardTabObject(
        icon: Icons.people,
        title: "Total Staffs",
        color: ColorManager.primary,
      ),
    ];
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        tabs.length,
        (i) => Expanded(
          child: Card(
            color: ColorManager.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tabs[i].title,
                        style: TextStyle(
                          color: ColorManager.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(tabs[i].icon, color: tabs[i].color),
                    ],
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      context.watch<EmployeesViewModel>().count[i].toString(),
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      "2% from yesterday",
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
