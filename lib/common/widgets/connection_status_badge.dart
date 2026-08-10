import 'package:flutter/material.dart';
import '../../services/offline_sync_service.dart';

/// Reusable Non-Pressable Connection Status Indicator Badge for Dashboards
class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineSyncService.instance,
      builder: (context, _) {
        final syncService = OfflineSyncService.instance;
        final isOnline = syncService.isOnline;
        final isSyncing = syncService.isSyncing;
        final pendingCount = syncService.pendingCount;

        Color badgeColor = Colors.green;
        IconData badgeIcon = Icons.wifi_rounded;
        String badgeText = 'Online';

        if (isSyncing) {
          badgeColor = Colors.blue;
          badgeIcon = Icons.sync_rounded;
          badgeText = 'Syncing ($pendingCount)...';
        } else if (!isOnline) {
          badgeColor = Colors.orange;
          badgeIcon = Icons.wifi_off_rounded;
          badgeText = pendingCount > 0 ? 'Offline ($pendingCount pending)' : 'Offline (Local)';
        }

        return Tooltip(
          message: 'Network connection status (Automatically monitored by system)',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
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
      },
    );
  }
}
