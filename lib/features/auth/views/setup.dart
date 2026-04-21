import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary1,
      body: Consumer<AuthViewModel>(
        builder: (context, state, __) {
          return PageView.builder(
            controller: state.pageController,
            itemCount: state.length,
            onPageChanged: state.onChanged,
            itemBuilder: (context, i) {
              return state.view;
            }
          );
        }
      ),
    );
  }
}
