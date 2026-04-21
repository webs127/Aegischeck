import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Future<UserCredential> register(String email, String password);
  Future<UserCredential> login(String email, String password);
  Future<void> logout();
  Stream<User?> authStateChanges();
}