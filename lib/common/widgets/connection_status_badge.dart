import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../services/sync_manager.dart';

/// Reusable Non-Pressable Connection Status Indicator Badge for Dashboards
class ConnectionStatusBadge extends StatefulWidget {
  const ConnectionStatusBadge({super.key});

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge> {
  int _pendingCount = 0;
  SyncManager? _syncManager;

  @override
  void initState() {
    super.initState();
    try {
      _syncManager = LocalDatabase.syncManager;
      _syncManager?.addListener(_onSyncChange);
      _updatePendingCount();
    } catch (_) {}
  }

  @override
  void dispose() {
    _syncManager?.removeListener(_onSyncChange);
    super.dispose();
  }

  void _onSyncChange() {
    _updatePendingCount();
    if (mounted) setState(() {});
  }

  Future<void> _updatePendingCount() async {
    if (_syncManager != null) {
      final count = await _syncManager!.getPendingCount();
      if (mounted) {
        setState(() {
          _pendingCount = count;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncManager = _syncManager;
    final isOnline = syncManager?.isOnline ?? true;
    final isSyncing = syncManager?.isProcessing ?? false;

    Color badgeColor = Colors.green;
    IconData badgeIcon = Icons.wifi_rounded;
    String badgeText = 'Online';

    if (isSyncing) {
      badgeColor = Colors.blue;
      badgeIcon = Icons.sync_rounded;
      badgeText = _pendingCount > 0 ? 'Syncing ($_pendingCount)' : 'Syncing';
    } else if (!isOnline) {
      badgeColor = Colors.orange;
      badgeIcon = Icons.wifi_off_rounded;
      badgeText = _pendingCount > 0 ? 'Offline ($_pendingCount)' : 'Offline';
    }

    return Tooltip(
      message: 'Network connection status (Automatically monitored by system)',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncing)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 6),
            Icon(badgeIcon, size: 14, color: badgeColor),
            const SizedBox(width: 4),
            Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
