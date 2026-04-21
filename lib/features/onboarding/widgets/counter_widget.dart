
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: List.generate(context.watch<OnboardingViewModel>().length, (i) {
        var current = context.read<OnboardingViewModel>().currentIndex;
        return Container(
          width: current == i ? 30 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: current == i
                ? ColorManager.primary
                : Colors.grey.withValues(alpha: .5),
          ),
        );
      }),
    );
  }
}
