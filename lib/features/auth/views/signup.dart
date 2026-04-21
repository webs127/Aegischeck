import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/shared/components/custom_textformfield.dart';
import 'package:aegischeck/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
              child: Icon(Icons.checklist, color: ColorManager.white),
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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Join AegisCheck to start trackingand managing attendance efficiently.",
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
                              key: auth.authKey,
                              child: Column(
                                spacing: 16,
                                children: [
                                  CustomTextFormField(
                                    controller: auth.username,
                                    labeltext: "Full name",
                                    prefixIcon: Icons.person_outline,
                                  ),
                                  CustomTextFormField(
                                    controller: auth.email,
                                    labeltext: "Work Email",
                                    prefixIcon: Icons.mail_outline,
                                  ),
                                  CustomTextFormField(
                                    controller: auth.department,
                                    labeltext: "Department",
                                    prefixIcon: Icons.mail_outline,
                                  ),
                                  CustomTextFormField(
                                    controller: auth.role,
                                    labeltext: "Role",
                                    prefixIcon: Icons.mail_outline,
                                  ),
                                  CustomTextFormField(
                                    controller: auth.orgCode,
                                    labeltext: "Organization Code",
                                    prefixIcon: Icons.code,
                                  ),
                                  CustomTextFormField(
                                    controller: auth.password,
                                    labeltext: "Password",
                                    prefixIcon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.remove_red_eye),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Row(
                                        spacing: 6,
                                        children: [
                                          Icon(Icons.chair),
                                          Text(
                                            "I agreee to the ",
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
                                      SizedBox(height: 5),
                                      Text(
                                        "Terms & Conditions",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: ColorManager.primary,
                                          fontWeight: FontWeight.w600,
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
                                    onPressed: () {
                                      auth.registerWithOrgCode();
                                    },
                                    child: Text(
                                      "Sign Up",
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
                          "Already have an account? ",
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
                            "Sign In",
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


