import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/auth/views/admin_login.dart';
import 'package:aegischeck/features/employees/viewmodels/employees_viewmodel.dart';
import 'package:aegischeck/features/auth/widgets/auto_behavior_widget.dart';
import 'package:aegischeck/features/auth/widgets/usecase_selector_widget.dart';
import 'package:aegischeck/routes/route_constants.dart';
import 'package:aegischeck/shared/components/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminLoginView extends StatelessWidget {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return context.watch<AuthViewModel>().isLoading ? Center(
      child: Icon(Icons.qr_code),
    ) : Column(
      spacing: 25,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Admin Portal Login",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: ColorManager.black,
          ),
        ),
        Text(
          "Enter your credentials to access the dashboard",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ColorManager.grey,
          ),
        ),
        Consumer<AuthViewModel>(
          builder: (context, login, __) {
            return Form(
              key: login.loginKey,
              child: Column(
                spacing: 25,
                children: [
                  CustomTextFormField(
                    controller: login.email,
                    labeltext: "Work Email",
                    prefixIcon: Icons.mail,
                  ),
                  CustomTextFormField(
                    controller: login.password,
                    labeltext: "Password",
                    prefixIcon: Icons.remove_red_eye,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          Icon(Icons.chair),
                          Text(
                            "Remember Me",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.withValues(alpha: .5),
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
                            color: ColorManager.primary1,
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
                    color: ColorManager.primary1,
                    onPressed: () async {
                      await login.login();
                      if (!context.mounted || login.error != null) {
                        return;
                      }

                      if (login.currentOrgId.isNotEmpty) {
                        context.read<EmployeesViewModel>().watchEmployeesByOrgId(
                          login.currentOrgId,
                        );
                      }
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
          }
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Need to register your organization? ",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(RouteConstants.setup);
              },
              child: Text(
                "Contact Sales",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OnboardingSetup1 extends StatefulWidget {
  const OnboardingSetup1({super.key});

  @override
  State<OnboardingSetup1> createState() => _OnboardingSetup1State();
}

class _OnboardingSetup1State extends State<OnboardingSetup1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Consumer<AuthViewModel>(
              builder: (conext, state, __) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorManager.primary1.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  "Onboarding . Step ${state.currentIndex + 1} of ${state.length}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.primary1,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "Setup your workspace",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.black,
                ),
              ),
            ),
            Center(
              child: Text(
                "Create a dedicated workspace for your organization. This will be the central hub for all your attendance data and reports.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.grey,
                ),
              ),
            ),
            SizedBox(),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                "Organization Logo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.black,
                ),
              ),
            ),
            Row(
              spacing: 10,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorManager.grey),
                  ),
                  child: Center(
                    child: Icon(Icons.add_a_photo, color: ColorManager.grey),
                  ),
                ),
                Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload Image",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "JPG, GIF or PNG. Max size of 2MB.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),

            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Consumer<AuthViewModel>(
                builder: (context, auth, __) {
                  return Form(
                    child: Column(
                      spacing: 25,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          controller: auth.orgName,
                          labeltext: "Organization Name",
                          prefixIcon: Icons.person,
                        ),
                        CustomTextFormField(
                          controller: auth.email,
                          labeltext: "Email Address",
                          prefixIcon: Icons.lock,
                        ),
                        CustomTextFormField(
                          controller: auth.username,
                          labeltext: "Username",
                          prefixIcon: Icons.lock,
                        ),
                        CustomTextFormField(
                          controller: auth.password,
                          labeltext: "Password",
                          prefixIcon: Icons.lock,
                        ),
                        CustomTextFormField(
                          labeltext: "Workspace URL",
                          prefixIcon: Icons.web,
                        ),
                        Text(
                          "Organization Size",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.black,
                          ),
                        ),
                        Consumer<AuthViewModel>(
                          builder: (context, state, __) {
                            return Row(
                              spacing: 10,
                              children: List.generate(
                                state.orgSizeLength,
                                (i) => OrganizationSizeWidget(
                                  onTap: () {
                                    state.onSelectOrganizationSize(i);
                                  },
                                  value: state.organizationSize[i],
                                  selected: state.checkSelected(i),
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          "Workdays",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.black,
                          ),
                        ),

                        Consumer<AuthViewModel>(
                          builder: (context, state, __) {
                            return Wrap(
                              spacing: 10,
                              children: List.generate(
                                state.workdays.length,
                                (i) => InkWell(
                                  onTap: () {
                                    state.onWorkDayStateChanged(i);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: state.workdaysstates[i]
                                            ? ColorManager.primary1
                                            : ColorManager.grey,
                                      ),
                                      color: state.workdaysstates[i]
                                          ? ColorManager.primary1
                                          : ColorManager.white,
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      state.workdays[i],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: state.workdaysstates[i]
                                            ? ColorManager.white
                                            : ColorManager.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          spacing: 10,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                context.pop(context);
                              },
                              shape: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: MaterialButton(
                                shape: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: ColorManager.primary1,
                                onPressed: () {
                                  context.read<AuthViewModel>().nextPage();
                                },
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                child: Text(
                                  "Continue to Use Case",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizationSizeWidget extends StatelessWidget {
  final int value;
  final bool selected;
  final VoidCallback? onTap;
  const OrganizationSizeWidget({
    super.key,
    this.onTap,
    this.selected = false,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? ColorManager.primary1
                : ColorManager.primary1.withValues(alpha: .2),
          ),
          color: selected
              ? ColorManager.primary1.withValues(alpha: .2)
              : ColorManager.grey.withValues(alpha: .2),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: selected ? ColorManager.primary1 : ColorManager.black,
          ),
        ),
      ),
    );
  }
}

class OnboardingSetup2 extends StatefulWidget {
  const OnboardingSetup2({super.key});

  @override
  State<OnboardingSetup2> createState() => _OnboardingSetup2State();
}

class _OnboardingSetup2State extends State<OnboardingSetup2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Consumer<AuthViewModel>(
              builder: (conext, state, __) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorManager.primary1.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  "Onboarding . Step ${state.currentIndex + 1} of ${state.length}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.primary1,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "Select your use case",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.black,
                ),
              ),
            ),
            Center(
              child: Text(
                "Pick the setup that best matches your environment. You can also describe a custom workflow and AegisCheck will configure labels, attendance logic, and reporting around it.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.grey,
                ),
              ),
            ),
            
            Consumer<AuthViewModel>(
              builder: (context, state, __) {
                return Column(
                  spacing: 20,
                  children: [
                    Row(
                      spacing: 10,
                      children: List.generate(
                        2,
                        (i) => UsecaseSelectorWidget(
                          text: state.usecases[i].type,
                          icon: state.usecases[i].icon,
                          ontap: () {
                            state.onSelectUseCase(i);
                          },
                          selected: state.checkUseCaseSelected(i),
                          description: state.usecases[i].description,
                        ),
                      ),
                    ),
                    Row(
                      spacing: 10,
                      children: List.generate(
                        2,
                        (i) => UsecaseSelectorWidget(
                          icon: state.usecases[i + 2].icon,
                          ontap: () {
                            state.onSelectUseCase(i + 2);
                          },
                          selected: state.checkUseCaseSelected(i + 2),
                          text: state.usecases[i + 2].type,
                          description: state.usecases[i + 2].description,
                        ),
                      ),
                    ),
                    UsecaseSelectorWidget(
                      expand: false,
                      icon: state.usecases[state.usecaseLength - 1].icon,
                      ontap: () {
                        state.onSelectUseCase(state.usecaseLength - 1);
                      },
                      selected: state.checkUseCaseSelected(
                        state.usecaseLength - 1,
                      ),
                      text: state.usecases[state.usecaseLength - 1].type,
                      description:
                          state.usecases[state.usecaseLength - 1].description,
                    ),
                  ],
                );
              },
            ),
            CustomTextFormField(
              labeltext: "Custom setup description",
              prefixIcon: Icons.description,
            ),
            Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "App behavior that will be configured",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.black,
                        ),
                      ),
                      Text(
                        "Auto-generated",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorManager.primary1,
                        ),
                      ),
                    ],
                  ),
                  Consumer<AuthViewModel>(
                    builder: (context, state, __) {
                      return Column(
                        spacing: 20,
                        children: [
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              2,
                              (i) => AutoConfiguredBehaviourWidget(
                                text: state.autoconfiguredtexts[i].text,
                                description:
                                    state.autoconfiguredtexts[i].description,
                              ),
                            ),
                          ),
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              2,
                              (i) => AutoConfiguredBehaviourWidget(
                                text: state.autoconfiguredtexts[i + 2].text,
                                description: state
                                    .autoconfiguredtexts[i + 2]
                                    .description,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Row(
              spacing: 10,
              children: [
                MaterialButton(
                  onPressed: () {
                    context.read<AuthViewModel>().previousPage();
                  },
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.black,
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: ColorManager.primary1,
                    onPressed: () {
                      context.read<AuthViewModel>().nextPage();
                    },
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Text(
                      "Continue Setup",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSetup3 extends StatefulWidget {
  const OnboardingSetup3({super.key});

  @override
  State<OnboardingSetup3> createState() => _OnboardingSetup3State();
}

class _OnboardingSetup3State extends State<OnboardingSetup3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Consumer<AuthViewModel>(
              builder: (conext, state, __) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorManager.primary1.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  "Onboarding . Step ${state.currentIndex + 1} of ${state.length}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.primary1,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "Invite Your Team",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.black,
                ),
              ),
            ),
            Center(
              child: Text(
                "Add employees or administrators. They will receive an email invitation to download the app and join your organization.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.grey,
                ),
              ),
            ),
            SizedBox(),
            Column(
              spacing: 20,
              children: List.generate(
                3,
                (i) => TeamMemberTextFormFieldWidget(),
              ),
            ),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add, color: ColorManager.primary1),
                label: Text(
                  "Add another member",
                  style: TextStyle(color: ColorManager.primary1),
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              spacing: 10,
              children: [
                MaterialButton(
                  onPressed: () {
                    context.read<AuthViewModel>().previousPage();
                  },
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.black,
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: ColorManager.primary1,
                    onPressed: () async {
                      final auth = context.read<AuthViewModel>();
                      final success = await auth.register();
                      if (!context.mounted) {
                        return;
                      }

                      if (!success) {
                        final message = auth.error ?? 'Registration failed';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        return;
                      }

                      context.goNamed(RouteConstants.platform);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Text(
                      "Complete Setup",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showCompleteSetUp(
    BuildContext context,
    List<OnboardingSetupObject> completeSetpData,
  ) {
    return showAdaptiveDialog(
      barrierColor: ColorManager.background,
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 20,
          children: [
            Row(
              spacing: 10,
              children: [
                Icon(Icons.qr_code, color: ColorManager.primary1),
                Text(
                  "AegisCheck",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.black,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width / 1.5,
              color: ColorManager.white,
              child: Column(
                spacing: 20,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.qr_code, color: ColorManager.white),
                  ),
                  Text(
                    "AegisCheck",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.black,
                    ),
                  ),
                  Text(
                    "Your workspace has been successfully created. Your team invitations have been sent.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.grey,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorManager.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      spacing: 20,
                      children: List.generate(
                        completeSetpData.length,
                        (i) => Row(
                          spacing: 10,
                          children: [
                            Icon(
                              completeSetpData[i].icon,
                              color: ColorManager.primary1,
                            ),
                            Text(
                              completeSetpData[i].left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: ColorManager.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width / 1.5,
                    onPressed: () {
                      context.pushNamed(RouteConstants.landing);
                    },
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: ColorManager.primary1,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Text(
                      "Go to Admin Dashboard",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("Download Mobile App"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamMemberTextFormFieldWidget extends StatelessWidget {
  const TeamMemberTextFormFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        Expanded(
          flex: 3,
          child: CustomTextFormField(
            labeltext: "Team Member Email",
            prefixIcon: Icons.person,
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            labeltext: "Role",
            prefixIcon: Icons.person,
          ),
        ),
      ],
    );
  }
}
