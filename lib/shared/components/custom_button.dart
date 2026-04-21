
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Widget child;
  const CustomButton({super.key, this.color, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MaterialButton(
        shape: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        color: color ?? ColorManager.primary,
        onPressed: onPressed,
        height: 50,
        child: child,
      ),
    );
  }
}