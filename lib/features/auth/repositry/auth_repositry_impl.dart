import 'package:aegischeck/core/models/signup_data.dart';
import 'package:aegischeck/core/service/firestore_service.dart';
import 'package:aegischeck/features/auth/repositry/auth_repositry.dart';
import 'package:aegischeck/features/auth/service/auth_service.dart';
import 'package:aegischeck/features/auth/service/device_binding_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final DeviceBindingService _deviceBindingService;

  AuthRepositoryImpl(
    this._authService,
    this._firestoreService,
    this._deviceBindingService,
  );

  @override
  Future<String> registerAdmin(SignUpData data) async {
    try {
      debugPrint(
        '[AuthRepository.registerAdmin] Creating auth user for email=${data.email}',
      );
      final credential = await _authService.register(data.email, data.password);

      final uid = credential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-uid',
          message: 'Firebase returned an empty uid after registration.',
        );
      }

      final orgId = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint(
        '[AuthRepository.registerAdmin] Writing organization document. orgId=$orgId',
      );

      await _firestoreService.setData(
        collection: "organizations",
        docId: orgId,
        data: {
          "name": data.orgName,
          "orgCode": data.orgCode,
          "useCase": data.useCase,
          "workDays": data.workDays,
          "createdBy": uid,
          "createdAt": FieldValue.serverTimestamp(),
        },
      );

      debugPrint(
        '[AuthRepository.registerAdmin] Writing user profile. uid=$uid orgId=$orgId',
      );
      final shouldBindDevice = _deviceBindingService.isSupported;
      final userData = {
        "username": data.username,
        "email": data.email,
        "orgId": orgId,
        "role": "admin",
        "department": "",
        "status": "Absent",
        "createdAt": FieldValue.serverTimestamp(),
      };

      if (shouldBindDevice) {
        final deviceId = await _deviceBindingService.getDeviceId();
        final deviceName = await _deviceBindingService.getDeviceName();
        userData.addAll({
          "deviceId": deviceId,
          "deviceName": deviceName,
          "deviceBoundAt": FieldValue.serverTimestamp(),
        });
      }

      await _firestoreService.setData(
        collection: "users",
        docId: uid,
        data: userData,
      );

      debugPrint(
        '[AuthRepository.registerAdmin] Registration data write completed',
      );
      return orgId;
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository.registerAdmin] Failed: $e');
      debugPrint('[AuthRepository.registerAdmin] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _authService.authStateChanges();
  }

  @override
  Future<void> logout() {
    return _authService.logout();
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      debugPrint('[AuthRepository.login] Attempting login for email=$email');
      final userCredential = await _authService.login(email, password);
      final uid = userCredential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-uid',
          message: 'Firebase returned an empty uid after login.',
        );
      }

      try {
        await _enforceDeviceBinding(uid);
      } catch (e) {
        debugPrint('[AuthRepository.login] Device binding failure, forcing logout');
        await _authService.logout();
        rethrow;
      }

      debugPrint('[AuthRepository.login] Login success for email=$email');
      return uid;
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository.login] Login failed: $e');
      debugPrint('[AuthRepository.login] Stack: $stackTrace');
      rethrow;
    }
  }

  Future<void> _enforceDeviceBinding(String uid) async {
    if (!_deviceBindingService.isSupported) {
      debugPrint('[AuthRepository.login] Device binding skipped on unsupported platform.');
      return;
    }

    final currentDeviceId = await _deviceBindingService.getDeviceId();
    final currentDeviceName = await _deviceBindingService.getDeviceName();
    final snapshot = await _firestoreService.getData(
      collection: 'users',
      docId: uid,
    );
    final profileData = snapshot.data() as Map<String, dynamic>?;

    if (profileData == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'User profile not found during device binding.',
      );
    }

    final storedDeviceId = (profileData['deviceId'] ?? '').toString().trim();

    if (storedDeviceId.isEmpty) {
      debugPrint('[AuthRepository.login] Binding device for uid=$uid deviceId=$currentDeviceId');
      await _firestoreService.updateData(
        collection: 'users',
        docId: uid,
        data: {
          'deviceId': currentDeviceId,
          'deviceName': currentDeviceName,
          'deviceBoundAt': FieldValue.serverTimestamp(),
        },
      );
      return;
    }

    if (storedDeviceId != currentDeviceId) {
      await _authService.logout();
      throw FirebaseAuthException(
        code: 'device-locked',
        message: 'This account is linked to another device.',
      );
    }
  }

  @override
  Future<void> updateUserStatus({
    required String uid,
    required String status,
  }) async {
    await _firestoreService.updateData(
      collection: 'users',
      docId: uid,
      data: {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      debugPrint('[AuthRepository.getUserProfile] Reading users/$uid');
      final snapshot = await _firestoreService.getData(
        collection: "users",
        docId: uid,
      );

      if (!snapshot.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'User profile not found',
        );
      }

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'invalid-data',
          message: 'User profile is empty',
        );
      }

      return {'id': snapshot.id, ...data};
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository.getUserProfile] Failed: $e');
      debugPrint('[AuthRepository.getUserProfile] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<String> registerWithOrgCode(SignUpWithOrgCodeData data) async {
    try {
      debugPrint(
        '[AuthRepository.registerWithOrgCode] Finding Org ID for email=${data.email}',
      );
      final orgId = await _firestoreService.query(
        collection: "organizations",
        query: data.orgCode,
      );
      debugPrint(
        '[AuthRepository.registerWithOrgCode] found Org ID for email=${data.email}, Org ID = $orgId',
      );

      debugPrint(
        '[AuthRepository.registerWithOrgCode] Creating auth user for email=${data.email}',
      );
      final userCredential = await _authService.register(
        data.email,
        data.password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-uid',
          message: 'Firebase returned an empty uid after registration.',
        );
      }

      final userData = {
        "fullname": data.fullname,
        "email": data.email,
        "orgId": orgId,
        "role": data.role.trim(),
        "department": data.department.trim(),
        "status": data.status.trim().isEmpty ? 'Absent' : data.status.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      };

      if (_deviceBindingService.isSupported) {
        final deviceId = await _deviceBindingService.getDeviceId();
        final deviceName = await _deviceBindingService.getDeviceName();
        userData.addAll({
          'deviceId': deviceId,
          'deviceName': deviceName,
          'deviceBoundAt': FieldValue.serverTimestamp(),
        });
      }

      await _firestoreService.setData(
        collection: "users",
        docId: uid,
        data: userData,
      );
      return orgId;
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository.registerWithOrgCode] Failed: $e');
      debugPrint('[AuthRepository.registerWithOrgCode] Stack: $stackTrace');
      rethrow;
    }
  }
}
