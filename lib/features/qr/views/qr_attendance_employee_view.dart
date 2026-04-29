import 'dart:async';
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/core/services/location_service.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/qr/models/qr_attendance_action.dart';
import 'package:aegischeck/features/qr/models/qr_attendance_payload.dart';
import 'package:aegischeck/features/qr/services/attendance_policy_utils.dart';
import 'package:aegischeck/routes/route_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrAttendanceEmployeeView extends StatefulWidget {
  const QrAttendanceEmployeeView({super.key});

  @override
  State<QrAttendanceEmployeeView> createState() =>
      _QrAttendanceEmployeeViewState();
}

class _QrAttendanceEmployeeViewState extends State<QrAttendanceEmployeeView> {
  Timer? _timer;
  Timer? _policyTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _policySubscription;
  QrAttendanceAction _selectedAction = QrAttendanceAction.signIn;
  QrAttendancePayload? _payload;
  String? _errorMessage;
  int _remainingSeconds = QrAttendancePayload.expiryWindowMs ~/ 1000;
  bool _loading = false;
  AttendancePolicy _policy = attendancePolicyFromSettings(null, DateTime.now());
  bool _canSignIn = true;
  bool _canSignOut = true;
  String? _policyMessage;
  Map<String, dynamic>? _settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primeAuthContext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _policyTimer?.cancel();
    _policySubscription?.cancel();
    super.dispose();
  }

  Future<void> _primeAuthContext() async {
    setState(() {
      _loading = true;
    });

    final auth = context.read<AuthViewModel>();
    final orgId = await auth.ensureOrgContext();
    final userId = auth.id.trim();

    if (orgId != null && orgId.isNotEmpty) {
      await _loadAttendancePolicy(orgId);
      _listenAttendancePolicy(orgId);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      if (orgId == null || orgId.isEmpty || userId.isEmpty) {
        _errorMessage = 'Sign in again to generate your attendance QR code.';
      } else if (_errorMessage?.contains('expired') ?? false) {
        _errorMessage = null;
      }
    });

    _policyTimer?.cancel();
    _policyTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) {
        return;
      }
      _refreshActionAvailability();
    });
  }

  Future<void> _loadAttendancePolicy(String orgId) async {
    try {
      final orgSnapshot = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .get();
      final orgData = orgSnapshot.data();
        final settingsRaw = orgData == null ? null : orgData['settings'];
        final settings = settingsRaw is Map<String, dynamic>
          ? settingsRaw
          : null;

      if (!mounted) {
        return;
      }

      setState(() {
        _policy = attendancePolicyFromSettings(settings, DateTime.now());
        _settings = settings;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _policy = attendancePolicyFromSettings(null, DateTime.now());
      });
      _refreshActionAvailability();
    }
  }

  void _listenAttendancePolicy(String orgId) {
    _policySubscription?.cancel();
    _policySubscription = FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .snapshots()
        .listen(
          (snapshot) {
            final data = snapshot.data();
            final settingsRaw = data == null ? null : data['settings'];
            final settings = settingsRaw is Map<String, dynamic> ? settingsRaw : null;

            if (!mounted) {
              return;
            }

            setState(() {
              _policy = attendancePolicyFromSettings(settings, DateTime.now());
        _settings = settings;
            });
            _refreshActionAvailability();
          },
          onError: (error) {
            final errorText = error.toString();
            if (errorText.contains('permission-denied')) {
              _policySubscription?.cancel();
              _policySubscription = null;
              if (!mounted) {
                return;
              }

              setState(() {
                _policy = attendancePolicyFromSettings(null, DateTime.now());
                _errorMessage = 'Please sign in again to refresh your policy.';
              });
              _refreshActionAvailability();
              debugPrint(
                '[QrAttendanceEmployeeView] Policy listener stopped after permission-denied.',
              );
              return;
            }

            debugPrint(
              '[QrAttendanceEmployeeView] Policy listener error: $error',
            );
          },
        );
  }

  void _refreshActionAvailability() {
    final now = DateTime.now();
    final checkInTime = _policy.checkInTime;
    final checkOutTime = _policy.checkOutTime;
    final canSignIn = isSignInOpen(_policy, now);
    final canSignOut = isSignOutOpen(_policy, now);

    final messages = <String>[];
    if (!canSignIn && checkInTime != null) {
      final openAt = checkInTime.subtract(const Duration(minutes: 15));
      messages.add('Sign In opens at ${_formatTime(openAt)}');
    }
    if (!canSignOut && checkOutTime != null) {
      final openAt = checkOutTime.subtract(const Duration(minutes: 5));
      messages.add('Sign Out opens at ${_formatTime(openAt)}');
    }

    setState(() {
      _canSignIn = canSignIn;
      _canSignOut = canSignOut;
      _policyMessage = messages.isEmpty ? null : messages.join(' | ');
    });
  }

  Future<void> _generateQrCode(QrAttendanceAction action) async {
    _refreshActionAvailability();

    if (action == QrAttendanceAction.signIn && !_canSignIn) {
      setState(() {
        _errorMessage = _policyMessage ??
            'Sign In is not available yet. It opens 15 minutes before check-in.';
      });
      return;
    }

    if (action == QrAttendanceAction.signOut && !_canSignOut) {
      setState(() {
        _errorMessage = _policyMessage ??
            'Sign Out is not available yet. It opens 5 minutes before check-out.';
      });
      return;
    }

    final auth = context.read<AuthViewModel>();
    final orgId = await auth.ensureOrgContext();
    final userId = auth.id.trim();

    if (!mounted) {
      return;
    }

    if (orgId == null || orgId.isEmpty || userId.isEmpty) {
      setState(() {
        _errorMessage = 'Sign in again to generate your attendance QR code.';
        _payload = null;
        _remainingSeconds = 0;
      });
      return;
    }

    // Geo-fencing check
    final showOfficeRadius = _settings?['showOfficeRadius'] ?? false;
    Map<String, double>? locationData;
    if (showOfficeRadius) {
      final location = _settings?['location'];
      if (location is Map<String, dynamic>) {
        final orgLat = (location['lat'] as num?)?.toDouble() ?? 0.0;
        final orgLng = (location['lng'] as num?)?.toDouble() ?? 0.0;
        final allowedRadius = (_settings?['allowedRadius'] as num?)?.toInt() ?? 100;

        // Check if office location is set to reasonable values
        if ((orgLat.abs() < 1.0 && orgLng.abs() < 1.0) || orgLat.abs() > 90.0 || orgLng.abs() > 180.0) {
          setState(() {
            _errorMessage = 'Office location coordinates appear invalid. Please update them in settings.';
          });
          return;
        }

        final locationService = LocationService();
        
        // Check location services first
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _errorMessage = 'Location services are disabled. Please enable location services to generate QR code.';
          });
          return;
        }

        // Check permissions
        final hasPermission = await locationService.requestPermission();
        if (!hasPermission) {
          setState(() {
            _errorMessage = 'Location permission is required to generate QR code.';
          });
          return;
        }

        final position = await locationService.getCurrentPosition();
        if (position == null) {
          setState(() {
            _errorMessage = 'Unable to get current location. Please check GPS signal.';
          });
          return;
        }

        // Check accuracy
        if (position.accuracy > 50) {
          setState(() {
            _errorMessage = 'GPS accuracy is too low (${position.accuracy.round()}m). Please wait for better GPS signal.';
          });
          return;
        }

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          orgLat,
          orgLng,
        );

        if (distance > allowedRadius) {
          setState(() {
            _errorMessage = 'You are ${distance.round()}m from office. Allowed radius is ${allowedRadius}m.';
          });
          return;
        }

        // Get location for payload
        locationData = await locationService.getCurrentLocation();
      }
    }

    _issuePayload(
      userId: userId,
      orgId: orgId,
      action: action,
      lat: locationData?['lat'],
      lng: locationData?['lng'],
    );
  }

  void _issuePayload({
    required String userId,
    required String orgId,
    required QrAttendanceAction action,
    double? lat,
    double? lng,
  }) {
    final now = DateTime.now();
    _timer?.cancel();
    setState(() {
      _selectedAction = action;
      _payload = QrAttendancePayload(
        userId: userId,
        organizationId: orgId,
        type: action.value,
        timestamp: now.millisecondsSinceEpoch,
        lat: lat,
        lng: lng,
      );
      _remainingSeconds = QrAttendancePayload.expiryWindowMs ~/ 1000;
      _errorMessage = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsedMs = DateTime.now().millisecondsSinceEpoch -
          (_payload?.timestamp ?? now.millisecondsSinceEpoch);
      final remaining = QrAttendancePayload.expiryWindowMs - elapsedMs;

      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _payload = null;
          _remainingSeconds = 0;
          _errorMessage = 'This QR code has expired. Tap Sign In or Sign Out to generate a new one.';
        });
        return;
      }

      setState(() {
        _remainingSeconds = (remaining / 1000).ceil();
      });
    });
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = context.watch<AuthViewModel>();
    final userName = (auth.currentUserProfile?['username'] ??
            auth.currentUserProfile?['fullname'] ??
            auth.currentUserProfile?['email'] ??
            'Employee')
        .toString();

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
                color: ColorManager.primary1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.qr_code_2_outlined, color: ColorManager.white,),
            ),
            const Text(
              'AegisCheck',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthViewModel>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Card(
              color: ColorManager.white,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: ColorManager.background1,
                      child: Icon(
                        Icons.badge_outlined,
                        color: ColorManager.primary1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Generate a fresh sign-in or sign-out QR code for this device.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorManager.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _ActionCardButton(
                    title: 'Sign In',
                    icon: Icons.login_outlined,
                    selected: _selectedAction == QrAttendanceAction.signIn,
                    enabled: _canSignIn,
                    onTap: () => _generateQrCode(QrAttendanceAction.signIn),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCardButton(
                    title: 'Sign Out',
                    icon: Icons.logout_outlined,
                    selected: _selectedAction == QrAttendanceAction.signOut,
                    enabled: _canSignOut,
                    onTap: () => _generateQrCode(QrAttendanceAction.signOut),
                  ),
                ),
              ],
            ),
            if (_policyMessage != null)
              Text(
                _policyMessage!,
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Card(
              color: ColorManager.white,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            const Text(
                              'Your QR Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Expires in ${_formatCountdown(_remainingSeconds)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorManager.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.background1,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _selectedAction.label,
                            style: TextStyle(
                              color: ColorManager.primary1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: size.width,
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorManager.greybackground),
                        color: ColorManager.white,
                      ),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage != null
                              ? Center(
                                  child: Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : _payload == null
                                  ? Center(
                                      child: Text(
                                        'Tap Sign In or Sign Out to generate your QR code.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: ColorManager.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        QrImageView(
                                          data: _payload!.toRawJson(),
                                          size: 240,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape: QrEyeShape.square,
                                            color: ColorManager.black,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape:
                                                QrDataModuleShape.square,
                                            color: ColorManager.black,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Show this code to the admin scanner within 30 seconds.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: ColorManager.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                    ),
                    Text(
                      'The QR payload is generated locally and only appears after you choose Sign In or Sign Out.',
                      style: TextStyle(
                        color: ColorManager.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          context.pushNamed(RouteConstants.qrScanner);
                        },
                        icon: const Icon(Icons.qr_code_scanner_outlined),
                        label: const Text('Open Scanner'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionCardButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: !enabled
          ? Colors.grey.shade300
          : (selected ? ColorManager.primary1 : ColorManager.white),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            spacing: 8,
            children: [
              CircleAvatar(
                backgroundColor: !enabled
                    ? Colors.grey.shade400
                    : (selected
                        ? Colors.white.withValues(alpha: 0.16)
                        : ColorManager.background1),
                child: Icon(
                  icon,
                  color: !enabled
                      ? Colors.grey.shade700
                      : (selected
                          ? ColorManager.white
                          : ColorManager.primary1),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: !enabled
                      ? Colors.grey.shade700
                      : (selected ? ColorManager.white : ColorManager.black),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
