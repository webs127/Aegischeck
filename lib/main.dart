import 'package:aegischeck/core/service/firestore_service.dart';
import 'package:aegischeck/core/service/firestore_service_impl.dart';
import 'package:aegischeck/features/auth/repositry/auth_repositry.dart';
import 'package:aegischeck/features/auth/repositry/auth_repositry_impl.dart';
import 'package:aegischeck/features/auth/service/auth_service.dart';
import 'package:aegischeck/features/auth/service/auth_service_impl.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/employees/viewmodels/employees_viewmodel.dart';
import 'package:aegischeck/features/landing/viewmodels/landing_viewmodel.dart';
import 'package:aegischeck/features/landing/views/landing.dart';
import 'package:aegischeck/features/qr/repositories/offline_attendance_repository.dart';
import 'package:aegischeck/features/qr/services/connectivity_service.dart';
import 'package:aegischeck/features/qr/services/hybrid_qr_attendance_service.dart';
import 'package:aegischeck/features/qr/services/offline_attendance_sync_service.dart';
import 'package:aegischeck/features/qr/services/qr_attendance_service.dart';
import 'package:aegischeck/features/qr/services/qr_attendance_service_impl.dart';
import 'package:aegischeck/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:aegischeck/features/onboarding/views/onboarding.dart';
import 'package:aegischeck/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:aegischeck/firebase_options.dart';
import 'package:aegischeck/routes/route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingViewModel(),
          child: OnboardingScreen(),
        ),
        ChangeNotifierProvider(
          create: (_) => LandingViewModel(),
          child: LandingScreen(),
        ),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        // Firebase
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),

        ChangeNotifierProvider(
          create: (context) => EmployeesViewModel(
            context.read<FirebaseFirestore>(),
          ),
        ),

        // Offline & Connectivity Services
        Provider<ConnectivityService>(
          create: (_) => ConnectivityServiceImpl(),
        ),
        Provider<OfflineAttendanceRepository>(
          create: (_) => OfflineAttendanceRepositoryImpl(),
        ),

        // Online QR Service
        Provider<QrAttendanceService>(
          create: (context) =>
              QrAttendanceServiceImpl(context.read<FirebaseFirestore>()),
        ),

        // Hybrid QR Service (online + offline fallback)
        ProxyProvider<QrAttendanceService, QrAttendanceService>(
          update: (context, onlineService, _) =>
              HybridQrAttendanceService(
            onlineService,
            context.read<OfflineAttendanceRepository>(),
            context.read<ConnectivityService>(),
          ),
        ),

        // Sync Service - use implementation type for ChangeNotifierProvider
        ChangeNotifierProvider<OfflineAttendanceSyncServiceImpl>(
          create: (context) => OfflineAttendanceSyncServiceImpl(
            context.read<FirebaseFirestore>(),
            context.read<OfflineAttendanceRepository>(),
            context.read<ConnectivityService>(),
          ),
        ),

        // Services
        Provider<FirestoreService>(
          create: (context) =>
              FirestoreServiceImpl(context.read<FirebaseFirestore>()),
        ),

        Provider<AuthService>(
          create: (context) =>
              FirebaseAuthService(context.read<FirebaseAuth>()),
        ),
        // Repository
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
        ),

        // ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'AegisCheck',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const _AppScrollBehavior(),
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routerDelegate: AppRouter.router.routerDelegate,
      ),
    );
  }
}

class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
