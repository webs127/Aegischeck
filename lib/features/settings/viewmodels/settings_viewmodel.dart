import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsViewModel with ChangeNotifier {
  SettingsViewModel({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final TextEditingController orgname = TextEditingController();
  final TextEditingController orgId = TextEditingController();
  final TextEditingController orgCode = TextEditingController();
  final TextEditingController orgContact = TextEditingController();
  final TextEditingController timezone = TextEditingController();
  final TextEditingController dataFormat = TextEditingController();
  final TextEditingController checkInTime = TextEditingController();
  final TextEditingController checkOutTime = TextEditingController();
  final TextEditingController lateThreshold = TextEditingController();
  final TextEditingController qrExpiryDuration = TextEditingController();
  final TextEditingController orgWorkdays = TextEditingController();
  final TextEditingController allowedRadius = TextEditingController();

  final TextEditingController lat = TextEditingController();
  final TextEditingController lng = TextEditingController();
  bool strictMode = false;

  bool showOfficeRadius = false;

  onShowOfficeRadiusChanged(bool? value) {
    if (value == null) {
      showOfficeRadius = false;
    } else {
      showOfficeRadius = value;
    }
    print(showOfficeRadius);
    notifyListeners();
  }

  onStrictModeChanged(bool? value) {
    strictMode = value ?? false;
    notifyListeners();
  }

  bool selected = false;
  final List<bool> workdaysState = List.filled(7, false);
  List<String> workdays = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"];
  List<String> selectedWorkDays = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  bool _initialized = false;
  String _currentOrgId = '';
  Map<String, dynamic> _lastLoadedSettings = {};

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await loadSettings();
  }

  onWorkDaySelected(int index) {
    workdaysState[index] = !workdaysState[index];
    if (workdaysState[index] == true) {
      selectedWorkDays.add(workdays[index]);
    } else {
      selectedWorkDays.remove(workdays[index]);
    }
    orgWorkdays.text = selectedWorkDays.join(', ');
    notifyListeners();
  }

  bool isChecked = false;
  onCheckBoxChanged(bool? value) {
    isChecked = value!;
    notifyListeners();
  }

  Future<String?> _resolveOrganizationId() async {
    if (_currentOrgId.isNotEmpty) {
      return _currentOrgId;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return null;
    }

    final userSnapshot = await _firestore.collection('users').doc(uid).get();
    final userData = userSnapshot.data();
    final resolvedOrgId = (userData?['orgId'] ?? '').toString().trim();
    if (resolvedOrgId.isEmpty) {
      return null;
    }

    _currentOrgId = resolvedOrgId;
    return _currentOrgId;
  }

  Future<void> loadSettings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resolvedOrgId = await _resolveOrganizationId();
      if (resolvedOrgId == null) {
        errorMessage = 'Could not find organization for current user.';
        return;
      }

      final orgSnapshot = await _firestore
          .collection('organizations')
          .doc(resolvedOrgId)
          .get();
      final orgData = orgSnapshot.data() ?? <String, dynamic>{};
      final settings = (orgData['settings'] is Map<String, dynamic>)
          ? orgData['settings'] as Map<String, dynamic>
          : <String, dynamic>{};

      _lastLoadedSettings = settings;

      orgname.text = (settings['orgName'] ?? orgData['name'] ?? '').toString();
      orgId.text = resolvedOrgId;
      orgCode.text = (settings['orgCode'] ?? orgData['orgCode'] ?? '')
          .toString();
      orgContact.text = (settings['orgContact'] ?? '').toString();
      timezone.text = (settings['timezone'] ?? '').toString();
      dataFormat.text = (settings['dataFormat'] ?? '').toString();
      checkInTime.text = (settings['checkInTime'] ?? '').toString();
      checkOutTime.text = (settings['checkOutTime'] ?? '').toString();
      lateThreshold.text = (settings['lateThreshold'] ?? '').toString();

      final loadedDaysDynamic = settings['workDays'] ?? orgData['workDays'];
      if (loadedDaysDynamic is List) {
        selectedWorkDays = loadedDaysDynamic.map((e) => e.toString()).toList();
      } else {
        selectedWorkDays = [];
      }

      for (int i = 0; i < workdaysState.length; i++) {
        workdaysState[i] = selectedWorkDays.contains(workdays[i]);
      }
      orgWorkdays.text = selectedWorkDays.join(', ');

      showOfficeRadius = settings['showOfficeRadius'] ?? false;
      if (showOfficeRadius) {
        final location = settings['location'];
        if (location is Map<String, dynamic>) {
          lat.text = (location['lat'] ?? '').toString();
          lng.text = (location['lng'] ?? '').toString();
        }
        allowedRadius.text = (settings['allowedRadius'] ?? '').toString();
        strictMode = settings['strictMode'] ?? false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSettings() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resolvedOrgId = await _resolveOrganizationId();
      if (resolvedOrgId == null) {
        errorMessage = 'Could not find organization for current user.';
        return false;
      }

      final delDuplicatedWorkDays = selectedWorkDays.toSet().toList();

      final settingsData = <String, dynamic>{
        'orgName': orgname.text.trim(),
        'orgCode': orgCode.text.trim(),
        'orgContact': orgContact.text.trim(),
        'timezone': timezone.text.trim(),
        'dataFormat': dataFormat.text.trim(),
        'checkInTime': checkInTime.text.trim(),
        'checkOutTime': checkOutTime.text.trim(),
        'lateThreshold': lateThreshold.text.trim(),
        'workDays': delDuplicatedWorkDays,
        'showOfficeRadius': showOfficeRadius,
      };

      if (showOfficeRadius) {
        settingsData['location'] = {
          'lat': double.tryParse(lat.text.trim()) ?? 0.0,
          'lng': double.tryParse(lng.text.trim()) ?? 0.0,
        };
        settingsData['allowedRadius'] = int.tryParse(allowedRadius.text.trim()) ?? 100;
        settingsData['strictMode'] = strictMode;
      }

      await _firestore.collection('organizations').doc(resolvedOrgId).set({
        'settings': settingsData,
      }, SetOptions(merge: true));

      _lastLoadedSettings = settingsData;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> discardChanges() async {
    if (_lastLoadedSettings.isEmpty) {
      await loadSettings();
      return;
    }

    orgname.text = (_lastLoadedSettings['orgName'] ?? '').toString();
    orgCode.text = (_lastLoadedSettings['orgCode'] ?? '').toString();
    orgContact.text = (_lastLoadedSettings['orgContact'] ?? '').toString();
    timezone.text = (_lastLoadedSettings['timezone'] ?? '').toString();
    dataFormat.text = (_lastLoadedSettings['dataFormat'] ?? '').toString();
    checkInTime.text = (_lastLoadedSettings['checkInTime'] ?? '').toString();
    checkOutTime.text = (_lastLoadedSettings['checkOutTime'] ?? '').toString();
    lateThreshold.text = (_lastLoadedSettings['lateThreshold'] ?? '')
        .toString();

    final days = _lastLoadedSettings['workDays'];
    if (days is List) {
      selectedWorkDays = days.map((e) => e.toString()).toList();
    } else {
      selectedWorkDays = [];
    }

    for (int i = 0; i < workdaysState.length; i++) {
      workdaysState[i] = selectedWorkDays.contains(workdays[i]);
    }
    orgWorkdays.text = selectedWorkDays.join(', ');

    showOfficeRadius = _lastLoadedSettings['showOfficeRadius'] ?? false;
    if (showOfficeRadius) {
      final location = _lastLoadedSettings['location'];
      if (location is Map<String, dynamic>) {
        lat.text = (location['lat'] ?? '').toString();
        lng.text = (location['lng'] ?? '').toString();
      }
      allowedRadius.text = (_lastLoadedSettings['allowedRadius'] ?? '').toString();
      strictMode = _lastLoadedSettings['strictMode'] ?? false;
    } else {
      lat.clear();
      lng.clear();
      allowedRadius.clear();
      strictMode = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    orgname.dispose();
    orgId.dispose();
    orgCode.dispose();
    orgContact.dispose();
    timezone.dispose();
    dataFormat.dispose();
    checkInTime.dispose();
    checkOutTime.dispose();
    lateThreshold.dispose();
    orgWorkdays.dispose();
    allowedRadius.dispose();
    lat.dispose();
    lng.dispose();
    super.dispose();
  }
}
