import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/settings/widgets/extra_data_with_checkbox.dart';
import 'package:flutter/material.dart';

class SettingsSecurityAccessScreen extends StatefulWidget {
  const SettingsSecurityAccessScreen({super.key});

  @override
  State<SettingsSecurityAccessScreen> createState() =>
      _SettingsSecurityAccessScreenState();
}

class _SettingsSecurityAccessScreenState
    extends State<SettingsSecurityAccessScreen> {
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
                "QR Code Security",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                "Configure dynamic QR generation to prevent screenshots and unathorized proxy attendance.",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(),
              SizedBox(height: 10),

              SizedBox(
                width: 400,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "QR Code Expiry Duration",
                    labelStyle: TextStyle(
                      color: ColorManager.black,
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ExtraDataWithCheckBox(
                heading: "Dynamic Refreshing",
                subText:
                    "Automatically refresh the QR code when it expires to prevent misuse.",
              ),
              SizedBox(height: 5),
              ExtraDataWithCheckBox(
                heading: "Screenshot Prevention",
                subText:
                    "Blur the QR code if a screenshot is detected on employee's device (app only).",
              ),
              SizedBox(height: 20),
              Text(
                "Location & Network Restrictions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                "Restrict where and how attendance can be recorded.",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              ExtraDataWithCheckBox(
                heading: "Geofencing Restrictions",
                subText:
                    "Employees must be within the office radius to access their QR code.",
              ),
              SizedBox(height: 5),
              ExtraDataWithCheckBox(
                heading: "IP Network Binding",
                subText:
                    "Only allow scanning from registered company Wi-Fi networks",
              ),
              SizedBox(height: 20),
              Text(
                "Device Management",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                "Control the devices employees use for the AegisCheck app.",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              ExtraDataWithCheckBox(
                heading: "Single Device Binding",
                subText:
                    "Bind user accounts to a single mobile device to prevent credential sharing.",
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
                      "Save Security Settings",
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

class OrganizationLogo extends StatelessWidget {
  const OrganizationLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorManager.grey),
          ),
        ),
        Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                MaterialButton(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () {},
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  height: 50,
                  color: ColorManager.white,
                  child: Text(
                    "Change Logo",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.black,
                    ),
                  ),
                ),
                MaterialButton(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () {},
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  height: 50,
                  color: Colors.red,
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.white,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "JPG, GIF or PNG. Max size of 2MB.",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
