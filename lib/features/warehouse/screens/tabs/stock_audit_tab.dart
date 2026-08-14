import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/models/batch.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class StockAuditTab extends StatefulWidget {
  const StockAuditTab({super.key});

  @override
  State<StockAuditTab> createState() => _StockAuditTabState();
}

class _StockAuditTabState extends State<StockAuditTab> {
  final _formKey = GlobalKey<FormState>();
  final _physicalQtyController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _selectedProduct;
  StockBatch? _selectedBatch;

  @override
  void dispose() {
    _physicalQtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showNewAuditDialog() {
    final controller = context.read<WarehouseController>();
    final products = controller.products;
    final batches = controller.batches;

    if (products.isEmpty) return;

    setState(() {
      _selectedProduct = products.first;
      final productBatches = batches.where((b) => b.productId == _selectedProduct?.id).toList();
      _selectedBatch = productBatches.isNotEmpty ? productBatches.first : null;
      _physicalQtyController.clear();
      _notesController.clear();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogBatches = batches.where((b) => b.productId == _selectedProduct?.id).toList();

            return AlertDialog(
              title: const Text('Log Physical Stock Audit'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Selection
                      const Text('Select Product', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Product>(
                        value: _selectedProduct,
                        items: products.map<DropdownMenuItem<Product>>((p) {
                          return DropdownMenuItem<Product>(value: p, child: Text(p.name));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              _selectedProduct = val;
                              final productBatches = batches.where((b) => b.productId == val.id).toList();
                              _selectedBatch = productBatches.isNotEmpty ? productBatches.first : null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Batch Selection
                      const Text('Select Batch', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      if (dialogBatches.isEmpty)
                        const Text('No active batches for this product.', style: TextStyle(color: Colors.red, fontSize: 13))
                      else
                        DropdownButtonFormField<StockBatch>(
                          value: _selectedBatch,
                          items: dialogBatches.map((b) {
                            return DropdownMenuItem<StockBatch>(
                              value: b,
                              child: Text('${b.batchNumber} (System: ${b.quantity})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                _selectedBatch = val;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 16),

                      // System Stock (Info Only)
                      if (_selectedBatch != null) ...[
                        Text('System Stock Quantity: ${_selectedBatch!.quantity}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                        const SizedBox(height: 16),
                      ],

                      // Physical Count
                      const Text('Physical Stock Counted', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _physicalQtyController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter counted quantity';
                          final qty = int.tryParse(v);
                          if (qty == null || qty < 0) return 'Must be zero or positive';
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'e.g., 95'),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      const Text('Discrepancy Notes / Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(hintText: 'Missing boxes / damage found during shelf count...'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: dialogBatches.isEmpty
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          final physicalQty = int.parse(_physicalQtyController.text);
                          
                          final success = await controller.logPhysicalAudit(
                            productId: _selectedProduct!.id,
                            batchId: _selectedBatch!.id,
                            systemQuantity: _selectedBatch!.quantity,
                            physicalQuantity: physicalQty,
                            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                          );

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stock audit logged. Batch quantity updated.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage ?? 'Failed to log stock audit.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: const Text('Log Audit & Adjust'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<WarehouseController>();
    final audits = controller.audits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Physical Inventory Audit Logs',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showNewAuditDialog,
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Perform Stock Take / Audit'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: audits.isEmpty
              ? const Card(
                  child: Center(
                    child: Text('No physical audits recorded yet.'),
                  ),
                )
              : ListView.separated(
                  itemCount: audits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = audits[index];
                    
                    final isShortage = item.discrepancy < 0;
                    
                    Color statusColor = Colors.green;
                    String statusText = 'Match';
                    IconData statusIcon = Icons.check_circle_outline_rounded;

                    if (isShortage) {
                      statusColor = Colors.red;
                      statusText = 'Shortage (${item.discrepancy})';
                      statusIcon = Icons.trending_down_rounded;
                    } else if (item.discrepancy > 0) {
                      statusColor = Colors.blue;
                      statusText = 'Surplus (+${item.discrepancy})';
                      statusIcon = Icons.trending_up_rounded;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(statusIcon, color: statusColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.productName ?? 'Product'} (Batch: ${item.batchNumber ?? 'Unknown'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Audited on: ${DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt)} | By: ${item.auditorName ?? 'Staff'}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  if (item.notes != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Notes: ${item.notes}',
                                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Physical: ${item.physicalQuantity} (Sys: ${item.systemQuantity})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 10,
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
