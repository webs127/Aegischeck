import 'package:flutter/material.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() =>
      _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState
    extends State<SettingsNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Text(
      "Notifications",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    );
  }
}
