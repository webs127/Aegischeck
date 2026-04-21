# Offline-First Attendance System Implementation

## Overview

The offline-first attendance system allows the QR scanner to continue recording attendance when the device loses internet connectivity. All scans are stored locally and automatically synced to Firestore when connectivity is restored.

## Architecture

### Components

1. **OfflineAttendanceRecord Model** (`lib/features/qr/models/offline_attendance_record.dart`)
   - Hive-backed persistent model
   - Contains: userId, organizationId, type, timestamps, sync status
   - Maps to Firestore attendance collection

2. **OfflineAttendanceRepository** (`lib/features/qr/repositories/offline_attendance_repository.dart`)
   - Manages Hive database operations
   - Methods: saveRecord, getUnsyncedRecords, markAsSynced, markAsSyncFailed, etc.

3. **ConnectivityService** (`lib/features/qr/services/connectivity_service.dart`)
   - Monitors device network connectivity
   - Exposes stream of connectivity changes

4. **OfflineAttendanceSyncService** (`lib/features/qr/services/offline_attendance_sync_service.dart`)
   - Orchestrates syncing of offline records
   - Auto-syncs when connectivity is restored
   - Handles batch uploads and error tracking
   - Notifies UI of sync progress

5. **HybridQrAttendanceService** (`lib/features/qr/services/hybrid_qr_attendance_service.dart`)
   - Wraps QrAttendanceService with offline capability
   - Attempts online first, falls back to offline if no connectivity
   - Handles local validation when offline

6. **OfflineSyncStatusWidget** (`lib/features/qr/widgets/offline_sync_status_widget.dart`)
   - Reusable UI component for displaying sync status
   - Compact and full modes

## Flow Diagram

```
┌─────────────────────────────────────────────┐
│         Scan QR Code                        │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Check Connectivity   │
        └──────────┬───────────┘
                   │
       ┌───────────┴────────────┐
       │                        │
   ONLINE                   OFFLINE
       │                        │
       ▼                        ▼
┌──────────────┐        ┌──────────────────┐
│ Try Firestore│        │ Local Validation │
│  Transaction │        └────────┬─────────┘
└──────┬───────┘                 │
       │                         ▼
       │               ┌─────────────────────┐
       │               │ Check Expiry        │
       │               │ Check Duplicates    │
       │               │ Check Organization  │
       │               └────────┬────────────┘
       │                        │
       │                        ▼
       │               ┌──────────────────────┐
       │               │ Save to Hive + set   │
       │               │ synced = false       │
       │               └────────┬─────────────┘
       │                        │
       └────────────┬───────────┘
                    │
                    ▼
        ┌────────────────────────┐
        │ Return Success Result  │
        │ (Online or Offline)    │
        └────────────────────────┘
        
[Background Process]
    ▼
┌──────────────────────────┐
│ Monitor Connectivity     │
│ When Online:             │
│ - Fetch unsynced records │
│ - Upload to Firestore    │
│ - Update user status     │
│ - Mark as synced         │
└──────────────────────────┘
```

## Offline Validation

When scanning without internet (offline mode), the system validates:

1. **QR Expiry Check**: `(scanTimestamp - qrTimestamp) <= 90 seconds` (30s window + 60s clock skew tolerance)
2. **Organization Match**: Payload organizationId == scanner organizationId
3. **Duplicate Check**: Same user cannot sign-in/out twice on the same day locally
4. **Authorization**: Scanner must have admin role

## Sync Mechanism

### Starting the Sync Service

```dart
// In scanner view initState
final syncService = context.read<OfflineAttendanceSyncService>();
syncService.startAutoSync();
```

### Auto-Sync Process

1. Service monitors connectivity changes via `ConnectivityService`
2. When connectivity is restored to online state
3. Fetches all records with `synced == false`
4. For each unsynced record:
   - Checks if record already exists in Firestore (duplicate prevention)
   - Uploads to `attendance` collection
   - Updates user status (Present for sign-in, Absent for sign-out)
   - Marks record as `synced = true` in local storage
5. If upload fails, marks as `synced = false` with error message for retry

### Batch Upload

Records are uploaded individually to prevent cascading failures. If one record fails, others continue syncing.

## Database Structure

### Hive Box: `offline_attendance`

```dart
OfflineAttendanceRecord {
  id: String,                    // Unique UUID
  userId: String,
  organizationId: String,
  type: String,                  // "sign_in" or "sign_out"
  qrTimestamp: int,              // From QR payload
  scanTimestamp: int,            // When device scanned
  synced: bool,                  // Upload status
  createdAt: int,                // Local creation time
  syncError: String?,            // Error message if sync failed
}
```

### Firestore: `attendance` collection

When synced to Firestore, the record becomes:

```dart
{
  userId: String,
  organizationId: String,
  type: String,
  timestamp: ServerTimestamp,    // Official time (when synced)
  qrTimestamp: int,              // Original QR time
  createdAt: ServerTimestamp,    // Server creation time
}
```

## User Experience

### Scanner View

- **Online Badge**: Shows "Online" in green with cloud icon
- **Offline Badge**: Shows "Offline" in orange with cloud X icon inside scanner
- **Sync Status**: Displays pending/synced record count and progress
- **Messages**:
  - Online: "Attendance saved" (blue checkmark)
  - Offline: "Attendance saved offline. Will sync when connected." (green checkmark)
  - Network-level errors are handled gracefully

### Employee View

- Generates QR codes immediately (no changes needed)
- Can still generate QR codes while offline
- QR code is valid for 90 seconds (30s window + 60s tolerance)

## Error Handling

### Failed Sync

If a record fails to sync:
- Error message is stored in `syncError` field
- Record remains with `synced = false`
- Sync service retries every 2 seconds when connectivity is restored
- Admin can see failed records count in sync status widget

### Data Integrity

- No duplicate uploads: Checks Firestore before writing
- No data loss: Records persist in Hive until successfully synced
- Transaction safety: User status update happens atomically with attendance write

## Performance Considerations

- **Local Storage**: Hive is very fast for local writes
- **Batch Syncing**: Records uploaded one-by-one (not bulk) to prevent all-or-nothing failures
- **Network Monitoring**: Continuous monitoring with lightweight streams
- **Memory**: OfflineAttendanceRecord is lightweight with minimal footprint

## Dependencies Added

```yaml
hive: ^2.2.3
hive_flutter: ^1.1.0
uuid: ^4.8.0
```

(Note: `connectivity_plus` was already present)

## Integration Checklist

✅ 1. Updated pubspec.yaml with Hive dependencies
✅ 2. Created OfflineAttendanceRecord model
✅ 3. Created OfflineAttendanceRepository
✅ 4. Created ConnectivityService
✅ 5. Created OfflineAttendanceSyncService
✅ 6. Created HybridQrAttendanceService
✅ 7. Updated main.dart with Hive initialization and providers
✅ 8. Updated scanner view to show sync status and offline badge
✅ 9. Created OfflineSyncStatusWidget for reuse

## Testing

### Manual Testing Checklist

1. **Offline Scan**
   - [ ] Turn off WiFi
   - [ ] Scan QR code
   - [ ] Verify "Attendance saved offline" message
   - [ ] Check Hive contains the record

2. **Auto-Sync**
   - [ ] Turn WiFi back on
   - [ ] Verify sync status updates
   - [ ] Check Firestore attendance collection
   - [ ] Verify user.status updated (Present/Absent)

3. **Duplicate Prevention**
   - [ ] Try scanning same action twice (offline)
   - [ ] Verify "Duplicate attendance" error
   - [ ] Try after sync - should not allow online duplicate either

4. **Clock Skew**
   - [ ] Change device time forward by 60 seconds
   - [ ] Generate QR
   - [ ] Verify still accepted (within tolerance)
   - [ ] Change device time forward by 120 seconds
   - [ ] Generate QR
   - [ ] Verify rejected as expired

5. **Sync Error Recovery**
   - [ ] Simulate error (e.g., permissions issue)
   - [ ] Verify failed record stored with error
   - [ ] Fix the issue
   - [ ] Restart app
   - [ ] Verify auto-sync retries and succeeds

## Future Enhancements

1. **Granular Sync Status**: Show which records failed and why
2. **Manual Sync Button**: Allow admin to manually trigger sync from UI
3. **Offline Analytics**: Show stats of offline vs online scans
4. **Selective Cleanup**: Delete old synced records to free storage
5. **Conflict Resolution**: Handle rare cases where record exists but with different data
