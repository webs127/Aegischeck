
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';

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
