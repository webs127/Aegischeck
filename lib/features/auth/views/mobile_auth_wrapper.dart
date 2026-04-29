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
    final viewModel = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: viewModel.authState,
      builder: (context, snapshot) {
        if (viewModel.isAuthInProgress || snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: LoadingWidget()));
        }

        if (snapshot.hasData && !viewModel.isFullyAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.ensureOrgContext();
          });
          return const Scaffold(body: Center(child: LoadingWidget()));
        }

        if (snapshot.hasData && viewModel.isFullyAuthenticated) {
          return HomeScreen();
        }

        if (!snapshot.hasData) {
          return context.watch<AuthViewModel>().isMobileLogin
              ? const LoginScreen()
              : const SignupScreen();
        }

        return const Scaffold(body: Center(child: LoadingWidget()));
      },
    );
  }
}
