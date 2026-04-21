import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsOrganizationProfileScreen extends StatefulWidget {
  const SettingsOrganizationProfileScreen({super.key});

  @override
  State<SettingsOrganizationProfileScreen> createState() =>
      _SettingsOrganizationProfileScreenState();
}

class _SettingsOrganizationProfileScreenState
    extends State<SettingsOrganizationProfileScreen> {
  TimeOfDay _parseTimeOrNow(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return TimeOfDay.now();
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return TimeOfDay.now();
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return TimeOfDay.now();
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _format24h(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickClockTime(TextEditingController controller) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _parseTimeOrNow(controller.text.trim()),
    );

    if (selected == null) {
      return;
    }

    controller.text = _format24h(selected);
  }

  Future<void> _pickLateThreshold(SettingsViewModel settings) async {
    final currentValue = int.tryParse(settings.lateThreshold.text.trim()) ?? 0;
    final safeValue = currentValue.clamp(0, 1439);
    final initialTime = TimeOfDay(
      hour: safeValue ~/ 60,
      minute: safeValue % 60,
    );

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selected == null) {
      return;
    }

    final minutes = (selected.hour * 60) + selected.minute;
    settings.lateThreshold.text = minutes.toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: AlignmentGeometry.topLeft,
        child: SingleChildScrollView(
          child: Consumer<SettingsViewModel>(
            builder: (context, settings, __) {
              return Form(
                key: settings.key,
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Organization Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Manage your company's core information and branding.",
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorManager.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      "Organization Logo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    OrganizationLogo(),
                    SizedBox(height: 10),
                    Row(
                      spacing: 30,
                      children: [
                        CustomTextFormField(
                          controller: settings.orgname,
                          labelText: "Organization Name",
                        ),
                        CustomTextFormField(
                          controller: settings.orgId,
                          readOnly: true,
                          labelText: "Organization ID",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      spacing: 30,
                      children: [
                        CustomTextFormField(
                          controller: settings.orgCode,
                          readOnly: true,
                          labelText: "Organization Code",
                        ),
                        CustomTextFormField(
                          controller: settings.orgContact,
                          readOnly: true,
                          labelText: "Contact Email",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      spacing: 30,
                      children: [
                        CustomTextFormField(
                          controller: settings.timezone,
                          labelText: "Timezone",
                        ),
                        CustomTextFormField(
                          controller: settings.dataFormat,
                          labelText: "Date Format",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Text(
                      "Attendance Policies",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Configure global rules for employee attendance tracking.",
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
                        CustomTextFormField(
                          controller: settings.checkInTime,
                          onTap: () => _pickClockTime(settings.checkInTime),
                          labelText: "Standard Check-in Time",
                        ),
                        CustomTextFormField(
                          controller: settings.checkOutTime,
                          onTap: () => _pickClockTime(settings.checkOutTime),
                          labelText: "Standard Check-out Time",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      spacing: 30,
                      children: [
                        CustomTextFormField(
                          controller: settings.lateThreshold,
                          onTap: () => _pickLateThreshold(settings),
                          labelText: "Late Threshold(Minutes)",
                        ),
                        CustomTextFormField(
                          readOnly: true,
                          controller: settings.orgWorkdays,
                          labelText: "Work Days",
                        ),
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
                          onPressed: settings.isSaving
                              ? null
                              : () async {
                                  await settings.discardChanges();
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
                          onPressed: settings.isSaving
                              ? null
                              : () async {
                                  final isSaved = await settings.saveSettings();
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSaved
                                            ? "Settings updated successfully"
                                            : (settings.errorMessage ??
                                                  "Failed to update settings"),
                                      ),
                                    ),
                                  );
                                },
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool readOnly;
  final Future<void> Function()? onTap;
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final FocusNode _focusNode;
  bool _isOpeningPicker = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  Future<void> _handleFocusChange() async {
    if (!_focusNode.hasFocus || widget.onTap == null || _isOpeningPicker) {
      return;
    }

    _isOpeningPicker = true;
    await widget.onTap!.call();
    _focusNode.unfocus();
    _isOpeningPicker = false;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly || widget.onTap != null,
        onTap: widget.onTap == null
            ? null
            : () {
                widget.onTap!.call();
              },
        onTapOutside: (_) => _focusNode.unfocus(),
        decoration: InputDecoration(
          labelText: widget.labelText,
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
