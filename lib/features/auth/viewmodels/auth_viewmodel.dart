import 'package:aegischeck/core/models/signup_data.dart';
import 'package:aegischeck/core/service/org_code_generator.dart';
import 'package:aegischeck/features/auth/repositry/auth_repositry.dart';
import 'package:aegischeck/features/auth/views/admin_login.dart';
import 'package:aegischeck/features/auth/views/admin_onboarding_view_components.dart';
import 'package:aegischeck/features/auth/widgets/reusable_setup_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthViewModel with ChangeNotifier {
  PageController pageController = PageController();
  final List<ReusableSetupWidget> _views = [
    ReusableSetupWidget(
      headerTextLeft: "Workspace Foundation",
      headertextRight: "Secure Hub",
      headerRightColor: Colors.green,
      onboardingSetupObject: [
        OnboardingSetupObject(
          icon: Icons.shield,
          left:
              "Enterprise-grade security and data isolation for your organization.",
        ),
        OnboardingSetupObject(
          icon: Icons.people,
          left:
              "Centralized directory to manage all your staff, members, or students",
        ),
        OnboardingSetupObject(
          icon: Icons.web,
          left: "Dedicated workspace URL for easy access from anywhere.",
        ),
      ],
      footer:
          "Build the foundation of your attendance tracking. Aegischeck provides a secure, reliable workspace tailored to your entire organization.",
      subFooter: "Setup step for administrators",
      right: OnboardingSetup1(),
    ),

    ReusableSetupWidget(
      headerTextLeft: "Configured Experience",
      headertextRight: "Custom Flow",
      headerRightColor: Colors.orange,
      onboardingSetupObject: [
        OnboardingSetupObject(
          icon: Icons.local_fire_department,
          left:
              "Department-based attendance, team dashboards, and shift tracking.",
        ),
        OnboardingSetupObject(
          icon: Icons.school,
          left:
              "Class schedules, guardian reports, and student check-in visibility.",
        ),
        OnboardingSetupObject(
          icon: Icons.calendar_month,
          left:
              "Event entry mode, capacity tracking, and instant arrival summaries.",
        ),
        OnboardingSetupObject(
          icon: Icons.card_membership,
          left:
              "Membership access, recurring visits, and front-desk scan controls.",
        ),
      ],
      footer:
          "Choose a use case first and AegisCheck tailors attendance rules, dashboards, and onboarding guidance around the way your team works.",
      subFooter: "Setup step for administrators.",
      right: OnboardingSetup2(),
    ),

    ReusableSetupWidget(
      headerTextLeft: "Workspace Initialization",
      headertextRight: "Final Step",
      headerRightColor: Colors.orange,
      onboardingSetupObject: [
        OnboardingSetupObject(
          icon: Icons.shield,
          left: "Provisioning secure organizational environment.",
        ),
        OnboardingSetupObject(
          icon: Icons.menu,
          left: "applying chosen \"Organization\" templates and structures.",
        ),
        OnboardingSetupObject(
          icon: Icons.timelapse,
          left: "Awaiting timezone and schedule configurations.",
        ),
      ],
      footer:
          "Your workspace is the central hub where managers monitor attendance, pull reports, and adjust schedules for the entire organization.",
      subFooter: "Setup step for administrators.",
      right: OnboardingSetup3(),
    ),
  ];

  bool isMobileLogin = true;

  onMobileAuthChange() {
    isMobileLogin = !isMobileLogin;
    notifyListeners();
  }

  int selectedSize = 0;
  String selectedUsecase = "";

  List<int> organizationSize = [50, 200, 500, 1000];
  List<AutoConfiguredObject> autoconfiguredtexts = [
    AutoConfiguredObject(
      text: "Primary labels",
      description: "Staff, teams, departments, or custom member roles.",
    ),
    AutoConfiguredObject(
      text: "Attendance rules",
      description:
          "Shift windows, late thresholds, and sign-in/sign-out logic.",
    ),
    AutoConfiguredObject(
      text: "Dashboard modules",
      description: "Summary cards, attendance trends, and role-based insights.",
    ),
    AutoConfiguredObject(
      text: "Scanner workflow",
      description:
          "Reception, classroom, event gate, or custom checkpoint mode.",
    ),
  ];

  final List<UseCaseObject> usecases = [
    UseCaseObject(
      icon: Icons.church,
      type: "Organization",
      description:
          "For offices and distributed teams with shift attendance, departments, and manager approval flows.",
    ),
    UseCaseObject(
      icon: Icons.school,
      type: "School",
      description:
          "For students, classes, period-based attendance, and guardian- ready reporting.",
    ),
    UseCaseObject(
      icon: Icons.event,
      type: "Event",
      description:
          "For temporary check-ins, ticket scanning, capacity control, and fast arrival logs.",
    ),
    UseCaseObject(
      icon: Icons.sports_gymnastics,
      type: "Gym",
      description:
          "For member access, trainer visits, recurring plans, and front-desk scanning",
    ),
    UseCaseObject(
      icon: Icons.dashboard_customize,
      type: "Custom",
      description:
          "Describe your own attendance model and let the platform adapt naming, roles, reports, and scan rules to match it.",
    ),
  ];

  final List<String> workdays = [
    "Mon",
    "Tues",
    "Wed",
    "Thur",
    "Fri",
    "Sat",
    "Sun",
  ];

  final List<bool> workdaysstates = List.filled(7, false);
  final List<String> selectedWorkDays = [];

  onWorkDayStateChanged(int index) {
    workdaysstates[index] = !workdaysstates[index];
        if (workdaysstates[index] == true) {
        selectedWorkDays.add(workdays[index]);
      } else {
        selectedWorkDays.remove(workdays[index]);
      }
    notifyListeners();
    print(selectedWorkDays.toSet().toList());

  }


  int get usecaseLength => usecases.length;

  onSelectUseCase(int index) {
    selectedUsecase = usecases[index].type;
    notifyListeners();
  }

  bool checkUseCaseSelected(int index) {
    if (selectedUsecase == usecases[index].type) {
      return true;
    }
    return false;
  }

  int get orgSizeLength => organizationSize.length;

  onSelectOrganizationSize(int index) {
    selectedSize = organizationSize[index];
    notifyListeners();
  }

  bool checkSelected(int index) {
    if (selectedSize == organizationSize[index]) {
      return true;
    }
    return false;
  }

  int currentIndex = 0;

  int get length => _views.length;

  Widget get view => _views[currentIndex];

  onChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  nextPage() {
    pageController.nextPage(
      duration: Duration(seconds: 1),
      curve: Curves.easeIn,
    );
  }

  previousPage() {
    pageController.previousPage(
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  final AuthRepository _repo;

  AuthViewModel(this._repo);
  TextEditingController email = TextEditingController();
  TextEditingController orgName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController department = TextEditingController();
  TextEditingController role = TextEditingController();
  TextEditingController orgCode = TextEditingController();
  GlobalKey<FormState> authKey = GlobalKey<FormState>();
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  String? generatedInviteCode;

  Future<bool> register() async {
    isLoading = true;
    error = null;
    notifyListeners();
    debugPrint('[AuthViewModel.register] Starting admin registration flow');

    String orgCode = OrgCodeGenerator.generateCode(orgName: orgName.text);

    SignUpData signUpData = SignUpData(
      email: email.text,
      password: password.text,
      username: username.text,
      orgName: orgName.text,
      workDays: selectedWorkDays,
      useCase: selectedUsecase,
      orgSize: selectedSize,
      orgCode: orgCode,
    );

    try {
      debugPrint(
        '[AuthViewModel.register] Calling registerAdmin for email=${signUpData.email}',
      );
      final orgId = await _repo.registerAdmin(signUpData);
      debugPrint(
        '[AuthViewModel.register] registerAdmin success. orgId=$orgId',
      );
      return true;
    } catch (e, stackTrace) {
      error = e.toString();
      debugPrint('[AuthViewModel.register] Registration failed: $e');
      debugPrint('[AuthViewModel.register] Stack: $stackTrace');
      return false;
    } finally {
      isLoading = false;
      debugPrint(
        '[AuthViewModel.register] Completed. isLoading=$isLoading, error=$error, generatedInviteCode=$generatedInviteCode',
      );
      notifyListeners();
    }
  }

  Future<void> registerWithOrgCode() async {
    isLoading = true;
    error = null;
    notifyListeners();
    debugPrint(
      '[AuthViewModel.registerWithOrgCode] Starting user registration flow',
    );

    SignUpWithOrgCodeData signUpData = SignUpWithOrgCodeData(
      email: email.text,
      password: password.text,
      fullname: username.text,
      orgCode: orgCode.text,
      role: role.text,
      department: department.text,
      status: "Absent",
    );

    try {
      debugPrint(
        '[AuthViewModel.registerWithOrgCode] Calling registerWithOrgCode for email=${signUpData.email}',
      );
      final orgId = await _repo.registerWithOrgCode(signUpData);
      debugPrint(
        '[AuthViewModel.registerWithOrgCode] registerWithOrgCode success. orgId=$orgId',
      );
    } catch (e, stackTrace) {
      error = e.toString();
      debugPrint('[AuthViewModel.registerWithOrgCode] Registration failed: $e');
      debugPrint('[AuthViewModel.registerWithOrgCode] Stack: $stackTrace');
    } finally {
      isLoading = false;
      debugPrint(
        '[AuthViewModel.registerWithOrgCode] Completed. isLoading=$isLoading, error=$error,',
      );
      notifyListeners();
    }
  }

  Stream<User?> get authState => _repo.authStateChanges();

  bool isLoading = false;
  String? error = '';
  String id = '';
  String currentOrgId = '';
  String currentRole = '';
  Map<String, dynamic>? currentUserProfile;

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.logout();
      currentUserProfile = null;
      currentOrgId = '';
      currentRole = '';
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> login() async {
    isLoading = true;
    error = null;
    notifyListeners();

    debugPrint('[AuthViewModel.login] Login start for email=${email.text}');

    try {
      id = await _repo.login(email.text, password.text);
      currentUserProfile = await _repo.getUserProfile(id);
      currentOrgId = (currentUserProfile?['orgId'] ?? '').toString().trim();
      currentRole = (currentUserProfile?['role'] ?? '').toString().trim();

      if (currentOrgId.isEmpty) {
        throw Exception('Logged-in user has no orgId in users collection.');
      }

      debugPrint(
        '[AuthViewModel.login] Profile loaded. uid=$id role=$currentRole orgId=$currentOrgId',
      );
    } catch (e, stackTrace) {
      error = e.toString();
      notifyListeners();
      debugPrint('[AuthViewModel.login] Login failed: $error');
      debugPrint('[AuthViewModel.login] Stack: $stackTrace');
    }

    isLoading = false;
    debugPrint('[AuthViewModel.login] Login flow finished. error=$error');
    notifyListeners();
  }

  Future<String?> ensureOrgContext() async {
    if (currentOrgId.isNotEmpty) {
      return currentOrgId;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return null;
    }

    try {
      id = uid;
      currentUserProfile = await _repo.getUserProfile(uid);
      currentOrgId = (currentUserProfile?['orgId'] ?? '').toString().trim();
      currentRole = (currentUserProfile?['role'] ?? '').toString().trim();
      notifyListeners();
      return currentOrgId.isEmpty ? null : currentOrgId;
    } catch (e, stackTrace) {
      debugPrint('[AuthViewModel.ensureOrgContext] Failed: $e');
      debugPrint('[AuthViewModel.ensureOrgContext] Stack: $stackTrace');
      return null;
    }
  }
}

class UseCaseObject {
  final IconData icon;
  final String type;
  final String description;

  UseCaseObject({
    required this.icon,
    required this.type,
    required this.description,
  });
}

class AutoConfiguredObject {
  final String text;
  final String description;

  AutoConfiguredObject({required this.text, required this.description});
}
