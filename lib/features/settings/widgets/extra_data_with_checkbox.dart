import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExtraDataWithCheckBox extends StatelessWidget {
  final String heading;
  final String subText;
  const ExtraDataWithCheckBox({
    super.key, required this.heading, required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Selector<SettingsViewModel, bool>(
          builder: (context, check, __) {
            return Checkbox.adaptive(
              fillColor: WidgetStatePropertyAll(ColorManager.primary1),
              value: check,
              onChanged: context
                  .read<SettingsViewModel>()
                  .onCheckBoxChanged,
            );
          },
          selector: (__, vm) => vm.isChecked,
        ),
      ],
    );
  }
}
