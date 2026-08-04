import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class SystemLogsTab extends StatelessWidget {
  const SystemLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AdminController>();
    final logs = controller.auditLogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Activity & Audit Logs',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: logs.isEmpty
              ? const Card(
                  child: Center(
                    child: Text('No system logs recorded yet.'),
                  ),
                )
              : ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    Color actionColor = theme.primaryColor;
                    if (log.action.contains('CREATED')) {
                      actionColor = Colors.green;
                    } else if (log.action.contains('RESET') || log.action.contains('DEACTIVATED')) {
                      actionColor = Colors.orange;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: actionColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                log.action,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: actionColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.description,
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Logged by: ${log.actorName ?? 'System'} | Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
