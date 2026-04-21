import 'package:aegischeck/features/auth/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  @override
  Future<UserCredential> register(String email, String password) async {
    try {
      debugPrint(
        '[AuthService.register] Creating FirebaseAuth user for email=$email',
      );
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
        '[AuthService.register] FirebaseAuth user created successfully',
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService.register] FirebaseAuthException(${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[AuthService.register] Unexpected error: $e');
      debugPrint('[AuthService.register] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<UserCredential> login(String email, String password) async {
    try {
      debugPrint('[AuthService.login] Attempting sign in for email=$email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('[AuthService.login] Sign in successful');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService.login] FirebaseAuthException(${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[AuthService.login] Unexpected error: $e');
      debugPrint('[AuthService.login] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint('[AuthService.logout] Signing out current user');
      await _auth.signOut();
      debugPrint('[AuthService.logout] Sign out complete');
    } catch (e, stackTrace) {
      debugPrint('[AuthService.logout] Sign out failed: $e');
      debugPrint('[AuthService.logout] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
