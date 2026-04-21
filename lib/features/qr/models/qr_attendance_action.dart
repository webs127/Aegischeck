import 'package:flutter/material.dart';

enum QrAttendanceAction {
  signIn('sign_in', 'Sign In', Icons.login_outlined),
  signOut('sign_out', 'Sign Out', Icons.logout_outlined);

  const QrAttendanceAction(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static QrAttendanceAction? fromValue(String value) {
    for (final action in QrAttendanceAction.values) {
      if (action.value == value) {
        return action;
      }
    }
    return null;
  }
}
