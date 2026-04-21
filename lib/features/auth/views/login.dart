import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/shared/components/custom_textformfield.dart';
import 'package:aegischeck/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        automaticallyImplyLeading: false,
        title: Row(
          spacing: 8,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.qr_code, color: ColorManager.white),
            ),
            Text(
              "AegisCheck",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
      ),
      body: context.watch<AuthViewModel>().isLoading
          ? LoadingWidget()
          : Padding(
              padding: EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Sign in to your account to securely manage or record attendance.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 16,
                        ),
                        child: Consumer<AuthViewModel>(
                          builder: (context, auth, __) {
                            return Form(
                              key: auth.loginKey,
                              child: Column(
                                spacing: 16,
                                children: [
                                  CustomTextFormField(
                                    labeltext: "Email Address",
                                    controller: auth.email,
                                    prefixIcon: Icons.mail_outline,
                                  ),
                                  CustomTextFormField(
                                    labeltext: "Password",
                                    controller: auth.password,
                                    prefixIcon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.remove_red_eye),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        spacing: 6,
                                        children: [
                                          Icon(Icons.chair),
                                          Text(
                                            "Remember Me",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.withValues(
                                                alpha: .5,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: ColorManager.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  MaterialButton(
                                    height: 50,
                                    minWidth: MediaQuery.of(context).size.width,
                                    shape: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: ColorManager.primary,
                                    onPressed: () async {
                                      await auth.login();
                                      // if (!context.mounted || auth.error != null) {
                                      //   return;
                                      // }

                                      // if (auth.currentOrgId.isNotEmpty) {
                                      //   context
                                      //       .read<EmployeesViewModel>()
                                      //       .watchEmployeesByOrgId(
                                      //         auth.currentOrgId,
                                      //       );
                                      // }

                                      // context.pushNamed(RouteConstants.home);
                                    },
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<AuthViewModel>()
                              .onMobileAuthChange(),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
