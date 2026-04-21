import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';

class SidebarListTile extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? fontSize;
  final bool showIcon;
  final String text;
  final bool selected;
  const SidebarListTile({
    super.key,
    this.showIcon = true,
    this.onPressed,
    required this.text,
    required this.selected, this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        selected: selected,
        title: Row(
          spacing: 10,
          children: [
            showIcon ? Icon(
              Icons.qr_code_2,
              color: selected ? ColorManager.white : ColorManager.black,
            ) : SizedBox(),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.w600,
                color: selected ? ColorManager.white : ColorManager.black,
              ),
            ),
          ],
        ),
        onTap: onPressed,
        shape: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(7),
        ),
        selectedTileColor: ColorManager.primary1,
      ),
    );
  }
}
