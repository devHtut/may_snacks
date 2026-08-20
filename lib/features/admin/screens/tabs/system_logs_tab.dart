import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';
import 'package:may_snacks/models/audit_log.dart';

class SystemLogsTab extends StatefulWidget {
  const SystemLogsTab({super.key});

  @override
  State<SystemLogsTab> createState() => _SystemLogsTabState();
}

class _SystemLogsTabState extends State<SystemLogsTab> {
  String _searchQuery = '';
  String _selectedRoleFilter = 'ALL'; // 'ALL', 'SALES', 'MANAGER', 'ADMIN'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminController>().loadAllAdminData();
      }
    });
  }

  String _getRoleKey(AuditLog log) {
    final actor = (log.actorName ?? '').toLowerCase();
    final action = log.action.toLowerCase();
    final desc = log.description.toLowerCase();

    if (actor.contains('sales') || action.contains('order_submitted') || action.contains('shop_registered') || desc.contains('sales staff')) {
      return 'SALES';
    } else if (actor.contains('manager') || action.contains('stock_in') || action.contains('fulfilled') || action.contains('delivered') || action.contains('disposal_requested') || action.contains('physical_audit') || desc.contains('warehouse manager')) {
      return 'MANAGER';
    } else {
      return 'ADMIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AdminController>();
    final logs = controller.auditLogs;

    final salesCount = logs.where((l) => _getRoleKey(l) == 'SALES').length;
    final managerCount = logs.where((l) => _getRoleKey(l) == 'MANAGER').length;
    final adminCount = logs.where((l) => _getRoleKey(l) == 'ADMIN').length;

    final filteredLogs = logs.where((log) {
      final roleKey = _getRoleKey(log);
      if (_selectedRoleFilter != 'ALL' && roleKey != _selectedRoleFilter) {
        return false;
      }

      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;

      final actor = (log.actorName ?? '').toLowerCase();
      final action = log.action.toLowerCase();
      final desc = log.description.toLowerCase();

      return actor.contains(query) || action.contains(query) || desc.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'System Activity & Audit Logs',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Audit Logs',
              onPressed: () => controller.loadAllAdminData(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Bar
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search audit logs by actor name, action type, or description...',
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),

        // Role Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: _selectedRoleFilter == 'ALL',
                label: Text('All Logs (${logs.length})'),
                onSelected: (_) => setState(() => _selectedRoleFilter = 'ALL'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _selectedRoleFilter == 'SALES',
                avatar: const Icon(Icons.storefront_rounded, size: 14, color: Colors.blue),
                label: Text('Sales Staff ($salesCount)'),
                selectedColor: Colors.blue.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _selectedRoleFilter = 'SALES'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _selectedRoleFilter == 'MANAGER',
                avatar: const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.green),
                label: Text('Warehouse Manager ($managerCount)'),
                selectedColor: Colors.green.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _selectedRoleFilter = 'MANAGER'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _selectedRoleFilter == 'ADMIN',
                avatar: const Icon(Icons.admin_panel_settings_outlined, size: 14, color: Colors.purple),
                label: Text('Admin ($adminCount)'),
                selectedColor: Colors.purple.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _selectedRoleFilter = 'ADMIN'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: filteredLogs.isEmpty
              ? const Card(
                  child: Center(
                    child: Text('No matching audit logs found.'),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredLogs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final roleKey = _getRoleKey(log);

                    Color roleColor = Colors.purple;
                    IconData roleIcon = Icons.admin_panel_settings_rounded;
                    String roleLabel = 'Admin';

                    if (roleKey == 'SALES') {
                      roleColor = Colors.blue;
                      roleIcon = Icons.storefront_rounded;
                      roleLabel = 'Sales Staff';
                    } else if (roleKey == 'MANAGER') {
                      roleColor = Colors.green;
                      roleIcon = Icons.inventory_2_rounded;
                      roleLabel = 'Warehouse Manager';
                    }

                    Color actionColor = roleColor;
                    if (log.action.contains('CREATED') || log.action.contains('APPROVED') || log.action.contains('FULFILLED')) {
                      actionColor = Colors.green;
                    } else if (log.action.contains('CANCELLED') || log.action.contains('REJECTED') || log.action.contains('DEACTIVATED') || log.action.contains('DELETED')) {
                      actionColor = Colors.redAccent;
                    } else if (log.action.contains('SUBMITTED') || log.action.contains('REGISTERED')) {
                      actionColor = Colors.blue[700]!;
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
                                color: actionColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: actionColor.withValues(alpha: 0.3)),
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
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: roleColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(roleIcon, size: 12, color: roleColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              roleLabel,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: roleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Logged by: ${log.actorName ?? 'System'} | ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt)}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
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
