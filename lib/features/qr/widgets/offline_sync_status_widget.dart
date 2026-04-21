import 'package:aegischeck/features/qr/services/offline_attendance_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget that displays offline sync status
/// Shows pending records, failed records, and sync progress
class OfflineSyncStatusWidget extends StatelessWidget {
  final bool compact;

  const OfflineSyncStatusWidget({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
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

            if (compact) {
              return _buildCompact(status, hasUnsynced, pendingRecords);
            }

            return _buildFull(status, hasUnsynced, pendingRecords);
          },
        );
      },
    );
  }

  Widget _buildCompact(
    SyncStatusUpdate status,
    bool hasUnsynced,
    int pendingRecords,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasUnsynced ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasUnsynced ? Icons.cloud_upload : Icons.check_circle,
            color: hasUnsynced ? Colors.blue : Colors.green,
            size: 14,
          ),
          Text(
            hasUnsynced
              ? '$pendingRecords pending'
                : 'Synced',
            style: TextStyle(
              color: hasUnsynced ? Colors.blue : Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (status.isSyncing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(
                  hasUnsynced ? Colors.blue : Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFull(
    SyncStatusUpdate status,
    bool hasUnsynced,
    int pendingRecords,
  ) {
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
  }
}
