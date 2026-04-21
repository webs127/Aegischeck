
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String labeltext;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  const CustomTextFormField({
    super.key,
    required this.labeltext,
    required this.prefixIcon,
    this.suffixIcon, this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withValues(alpha: .1),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        labelText: labeltext,
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
