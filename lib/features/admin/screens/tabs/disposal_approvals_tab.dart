import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/disposal.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';
import '../../controllers/admin_controller.dart';

class DisposalApprovalsTab extends StatefulWidget {
  const DisposalApprovalsTab({super.key});

  @override
  State<DisposalApprovalsTab> createState() => _DisposalApprovalsTabState();
}

class _DisposalApprovalsTabState extends State<DisposalApprovalsTab> {
  Future<void> _handleDecision(String disposalId, bool isApprove) async {
    final controller = context.read<AdminController>();
    final warehouseController = context.read<WarehouseController>();

    final success = isApprove
        ? await controller.approveDisposalRequest(disposalId)
        : await controller.rejectDisposalRequest(disposalId);

    if (success && mounted) {
      // Reload warehouse controller as batch quantities are affected by write-offs
      await warehouseController.loadAllWarehouseData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disposal request successfully ${isApprove ? 'approved' : 'rejected'}.'),
          backgroundColor: isApprove ? Colors.green : Colors.orange,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'An error occurred.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AdminController>();
    
    // Read from the synchronized warehouse controller disposal list
    final warehouseController = context.watch<WarehouseController>();
    final disposalsList = warehouseController.disposals;
    final isLoading = controller.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory Disposal & Damage Approval Queue',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: disposalsList.isEmpty
              ? const Card(
                  child: Center(
                    child: Text('No disposal requests submitted yet.'),
                  ),
                )
              : ListView.separated(
                  itemCount: disposalsList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = disposalsList[index];

                    Color statusColor = Colors.orange;
                    IconData statusIcon = Icons.hourglass_empty_rounded;

                    if (item.status == DisposalStatus.approved) {
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle_outline_rounded;
                    } else if (item.status == DisposalStatus.rejected) {
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel_outlined;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(statusIcon, color: statusColor, size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.productName ?? 'Product'} (Batch: ${item.batchNumber ?? 'Unknown'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Requested Quantity: ${item.quantity} units',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reason: ${item.reason}',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Submitted by: ${item.requesterName ?? 'Warehouse Manager'} on ${DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item.status == DisposalStatus.pending)
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: isLoading ? null : () => _handleDecision(item.id, false),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: isLoading ? null : () => _handleDecision(item.id, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    ],
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.status.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                              ],
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
