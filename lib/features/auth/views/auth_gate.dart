import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/auth/views/admin_login.dart';
import 'package:aegischeck/features/landing/views/landing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: viewModel.authState,
      builder: (context, snapshot) {
        if (viewModel.isAuthInProgress || snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && !viewModel.isFullyAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.ensureOrgContext();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && viewModel.isFullyAuthenticated) {
          return LandingScreen();
        }

        if (!snapshot.hasData) {
          return AdminLoginScreen();
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}