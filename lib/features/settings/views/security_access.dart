import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/core/services/location_service.dart';
import 'package:aegischeck/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:aegischeck/features/settings/widgets/extra_data_with_checkbox.dart';
import 'package:aegischeck/shared/components/custom_textformfield_with_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                value: context.watch<SettingsViewModel>().showOfficeRadius,
                onChanged: context
                    .read<SettingsViewModel>()
                    .onShowOfficeRadiusChanged,
                heading: "Geofencing Restrictions",
                subText:
                    "Employees must be within the office radius to access their QR code.",
              ),
              context.watch<SettingsViewModel>().showOfficeRadius ? Selector<SettingsViewModel, TextEditingController>(
                builder: (context, value, child) => SizedBox(
                  width: 300,
                  child: CustomTextFormField(
                    controller: value,
                    labelText: "Allowed Radius (meters)",
                  ),
                ),
                selector: (__, vm) => vm.allowedRadius,
              ) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? SizedBox(height: 10) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? Selector<SettingsViewModel, TextEditingController>(
                builder: (context, value, child) => SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: value,
                    decoration: InputDecoration(
                      labelText: "Latitude",
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
                selector: (__, vm) => vm.lat,
              ) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? SizedBox(height: 10) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? Selector<SettingsViewModel, TextEditingController>(
                builder: (context, value, child) => SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: value,
                    decoration: InputDecoration(
                      labelText: "Longitude",
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
                selector: (__, vm) => vm.lng,
              ) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? SizedBox(height: 10) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? MaterialButton(
                color: ColorManager.primary1,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                onPressed: () async {
                  final locationService = LocationService();
                  context.read<SettingsViewModel>().lat.clear();
                  context.read<SettingsViewModel>().lng.clear();

                  final hasPermission = await locationService.requestPermission();
                  if (!hasPermission) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Location permission is required')),
                    );
                    return;
                  }

                  final location = await locationService.getCurrentLocation();
                  if (location != null) {
                    context.read<SettingsViewModel>().lat.text = location['lat']!.toStringAsFixed(6);
                    context.read<SettingsViewModel>().lng.text = location['lng']!.toStringAsFixed(6);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Location updated successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to get current location. Please check location services.')),
                    );
                  }
                },
                child: Text(
                  "Get Current Location",
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? SizedBox(height: 10) : SizedBox(),
              context.watch<SettingsViewModel>().showOfficeRadius ? ExtraDataWithCheckBox(
                value: context.watch<SettingsViewModel>().strictMode,
                onChanged: context.read<SettingsViewModel>().onStrictModeChanged,
                heading: "Strict Mode",
                subText: "Enforce strict location validation on scanner side.",
              ) : SizedBox(),
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
                    onPressed: () async {
                      final success = await context.read<SettingsViewModel>().discardChanges();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Changes discarded')),
                      );
                    },
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
                    onPressed: context.watch<SettingsViewModel>().isSaving
                        ? null
                        : () async {
                            final success = await context.read<SettingsViewModel>().saveSettings();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Security settings saved successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.read<SettingsViewModel>().errorMessage ?? 'Failed to save settings'),
                                ),
                              );
                            }
                          },
                    child: context.watch<SettingsViewModel>().isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.white),
                            ),
                          )
                        : Text(
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
