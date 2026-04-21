import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/qr/models/qr_attendance_result.dart';
import 'package:aegischeck/features/qr/services/connectivity_service.dart';
import 'package:aegischeck/features/qr/services/offline_attendance_sync_service.dart';
import 'package:aegischeck/features/qr/services/qr_attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrAttendanceScannerView extends StatefulWidget {
  const QrAttendanceScannerView({super.key});

  @override
  State<QrAttendanceScannerView> createState() =>
      _QrAttendanceScannerViewState();
}

class _QrAttendanceScannerViewState extends State<QrAttendanceScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _isProcessing = false;
  bool _isLoadingContext = true;
  bool _hasAccess = false;
  bool _isOnline = true;
  String _statusTitle = 'Ready to scan';
  String _statusMessage = 'Point the scanner at an attendance QR code.';
  Color _statusColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContext();
      _startSync();
      _monitorConnectivity();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadContext() async {
    final auth = context.read<AuthViewModel>();
    final orgId = await auth.ensureOrgContext();
    if (!mounted) {
      return;
    }

    final role = auth.currentRole.trim().toLowerCase();
    final hasAccess = orgId != null &&
        orgId.isNotEmpty &&
        (role == 'admin' || role.contains('admin'));

    setState(() {
      _isLoadingContext = false;
      _hasAccess = hasAccess;
      if (!hasAccess) {
        _statusTitle = 'Scanner locked';
        _statusMessage = 'Only admins can validate attendance on this device.';
        _statusColor = Colors.orange;
      }
    });
  }

  void _startSync() {
    try {
      final syncService = context.read<OfflineAttendanceSyncServiceImpl>();
      syncService.startAutoSync();
    } catch (e) {
      debugPrint('Failed to start sync: $e');
    }
  }

  void _monitorConnectivity() {
    try {
      final connectivityService = context.read<ConnectivityService>();
      connectivityService.onConnectivityChanged.listen((isOnline) {
        if (mounted) {
          setState(() {
            _isOnline = isOnline;
          });
        }
      });
    } catch (e) {
      debugPrint('Failed to monitor connectivity: $e');
    }
  }

  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isProcessing || !_hasAccess) {
      return;
    }

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((value) => value != null && value.trim().isNotEmpty, orElse: () => null);

    if (rawValue == null) {
      return;
    }

    _isProcessing = true;

    final auth = context.read<AuthViewModel>();
    final service = context.read<QrAttendanceService>();
    final result = await service.validateAndRecordAttendance(
      rawQrPayload: rawValue,
      scannerUserId: auth.id,
      scannerOrganizationId: auth.currentOrgId,
      scannerRole: auth.currentRole,
    );

    if (!mounted) {
      return;
    }

    _showResult(result);
    _isProcessing = false;

    if (result.isSuccess) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
  }

  void _showResult(QrAttendanceResult result) {
    final color = switch (result.outcome) {
      QrAttendanceOutcome.success => Colors.green,
      QrAttendanceOutcome.expired => Colors.orange,
      QrAttendanceOutcome.invalidOrganization => Colors.red,
      QrAttendanceOutcome.duplicate => Colors.deepOrange,
      QrAttendanceOutcome.unauthorized => Colors.red,
      QrAttendanceOutcome.invalidPayload => Colors.red,
      QrAttendanceOutcome.error => Colors.red,
    };

    setState(() {
      _statusTitle = switch (result.outcome) {
        QrAttendanceOutcome.success =>
          result.message.toLowerCase().contains('offline')
              ? 'Saved locally'
              : 'Attendance saved',
        QrAttendanceOutcome.expired => 'Expired QR',
        QrAttendanceOutcome.invalidOrganization => 'Organization mismatch',
        QrAttendanceOutcome.duplicate => 'Duplicate attendance',
        QrAttendanceOutcome.unauthorized => 'Unauthorized',
        QrAttendanceOutcome.invalidPayload => 'Invalid QR',
        QrAttendanceOutcome.error => 'Scan failed',
      };
      _statusMessage = result.message;
      _statusColor = color;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Attendance Scanner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            _buildConnectivityBadge(),
          ],
        ),
      ),
      body: Padding(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      _statusTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _statusColor,
                      ),
                    ),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorManager.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 400,
              child: Card(
                color: ColorManager.white,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: _isLoadingContext
                    ? const Center(child: CircularProgressIndicator())
                    : !_hasAccess
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 64,
                                    color: ColorManager.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Admin access required',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Only admin users from this organization can record attendance on the scanner device.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorManager.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              MobileScanner(
                                controller: _controller,
                                onDetect: _processBarcode,
                              ),
                              if (!_isOnline)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Icons.wifi_off,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        Text(
                                          'Offline Mode',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
              ),
            ),
            _buildSyncStatus(),
            Text(
              'Validation checks happen in-app before the attendance record is written to Firestore.',
              style: TextStyle(
                color: ColorManager.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: _isOnline ? Colors.green : Colors.orange,
            size: 16,
          ),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: _isOnline ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Consumer<OfflineAttendanceSyncServiceImpl>(
      builder: (context, syncService, child) {
        return StreamBuilder<SyncStatusUpdate>(
          stream: syncService.syncStatusStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final status = snapshot.data!;
            final pendingRecords = status.totalRecords - status.syncedRecords;

            if (status.totalRecords == 0 || pendingRecords <= 0) {
              return const SizedBox.shrink();
            }

            final hasUnsynced = pendingRecords > 0;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasUnsynced ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                border: Border.all(
                  color: hasUnsynced ? Colors.blue.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        hasUnsynced ? Icons.cloud_upload : Icons.check_circle,
                        color: hasUnsynced ? Colors.blue : Colors.green,
                        size: 18,
                      ),
                      Expanded(
                        child: Text(
                          hasUnsynced
                              ? '$pendingRecords records pending sync'
                              : 'All records synced',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasUnsynced ? Colors.blue : Colors.green,
                          ),
                        ),
                      ),
                      if (status.isSyncing)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              hasUnsynced ? Colors.blue : Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (status.failedRecords > 0)
                    Text(
                      '${status.failedRecords} records failed to sync (will retry)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
