import 'package:aegischeck/core/models/signup_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<String> registerAdmin(SignUpData data);
  Future<String> registerWithOrgCode(SignUpWithOrgCodeData data);
  Future<String> login(String email, String password);
  Future<void> updateUserStatus({required String uid, required String status});
  Future<Map<String, dynamic>> getUserProfile(String uid);
  Stream<User?> authStateChanges();
  Future<void> logout();
}
