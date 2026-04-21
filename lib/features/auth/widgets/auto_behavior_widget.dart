import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';

class AutoConfiguredBehaviourWidget extends StatelessWidget {
    final String text;
  final String description;
  const AutoConfiguredBehaviourWidget({super.key, required this.text, required this.description});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorManager.black,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorManager.grey,
            ),
          ),
        ],
      ),
    );
  }
}
