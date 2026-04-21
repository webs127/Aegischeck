import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/settings/widgets/extra_data_with_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsAttendancePoliciesScreen extends StatefulWidget {
  const SettingsAttendancePoliciesScreen({super.key});

  @override
  State<SettingsAttendancePoliciesScreen> createState() =>
      _SettingsAttendancePoliciesScreenState();
}

class _SettingsAttendancePoliciesScreenState
    extends State<SettingsAttendancePoliciesScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: AlignmentGeometry.topLeft,
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Work Hours & Days",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              SizedBox(height: 10),
              Text(
                "Define the standard working hours and operational days for your organization.",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(),
              SizedBox(height: 7),
              Text(
                "Work Days",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Consumer<AuthViewModel>(
                builder: (context, vm, child) {
                  return Row(
                    spacing: 10,
                    children: List.generate(
                      7,
                      (i) => WorkDaysTile(
                        selected: vm.workdaysstates[i],
                        onTap: () {
                          vm.onWorkDayStateChanged(i);
                        },
                        text: vm.workdays[i],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Row(
                spacing: 30,
                children: [
                  CustomTextFormField(labelText: "Standard Check-in Time"),
                  CustomTextFormField(labelText: "Standard Check-out Time"),
                ],
              ),
              SizedBox(height: 10),
              Row(
                spacing: 30,
                children: [
                  CustomTextFormField(labelText: "Half-Day Threshold (Hours)"),
                  CustomTextFormField(
                    labelText: "Lunch Break Duration (Minutes)",
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Lateness & Absences",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              Text(
                "Configure rules and grace periods for late arrivals and absences.",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              Row(
                spacing: 30,
                children: [
                  CustomTextFormField(labelText: "Grace Period (Minutes)"),
                  CustomTextFormField(
                    labelText: "Mark as Absent After (Minutes)",
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Overtime Tracking",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              Text(
                "manage how overtime is calculated and logged.",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(),
              ExtraDataWithCheckBox(
                heading: "Enable Overtime Calculation",
                subText: "Track hours worked beyond the standard check-out time.",
              ),
              SizedBox(height: 10),
              Row(
                spacing: 30,
                children: [
                  CustomTextFormField(labelText: "Mininum Overtime (Minutes)"),
                  CustomTextFormField(labelText: "Overtime Approval"),
                ],
              ),
              SizedBox(height: 20),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 50,
                    onPressed: () {},
                    child: Text(
                      "Discard Changes",
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorManager.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  MaterialButton(
                    color: ColorManager.primary1,
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 50,
                    onPressed: () {},
                    child: Text(
                      "Save Settings",
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorManager.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class WorkDaysTile extends StatelessWidget {
  final bool selected;
  final String text;
  final VoidCallback? onTap;
  const WorkDaysTile({
    super.key,
    required this.text,
    this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? ColorManager.primary1 : ColorManager.white,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? ColorManager.white : ColorManager.black,
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  const CustomTextFormField({super.key, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: ColorManager.black,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
