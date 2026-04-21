import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/auth/views/login.dart';
import 'package:aegischeck/features/auth/views/signup.dart';
import 'package:aegischeck/features/home/views/home.dart';
import 'package:aegischeck/shared/widgets/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileAuthWrapper extends StatelessWidget {
  const MobileAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: viewModel.authState,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: LoadingWidget()));
        }
        // Logged in
        if (snapshot.hasData) {
          return HomeScreen();
        }
        // Logged out
        return context.watch<AuthViewModel>().isMobileLogin
            ? const LoginScreen()
            : const SignupScreen();
      },
    );
  }
}
