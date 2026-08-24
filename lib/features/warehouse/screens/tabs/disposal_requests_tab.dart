import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/models/batch.dart';
import 'package:may_snacks/models/disposal.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class DisposalRequestsTab extends StatefulWidget {
  const DisposalRequestsTab({super.key});

  @override
  State<DisposalRequestsTab> createState() => _DisposalRequestsTabState();
}

class _DisposalRequestsTabState extends State<DisposalRequestsTab> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  Product? _selectedProduct;
  StockBatch? _selectedBatch;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showNewRequestDialog() {
    final controller = context.read<WarehouseController>();
    final products = controller.products;
    final batches = controller.batches;

    if (products.isEmpty) return;

    setState(() {
      _selectedProduct = products.first;
      final productBatches = batches.where((b) => b.productId == _selectedProduct?.id).toList();
      _selectedBatch = productBatches.isNotEmpty ? productBatches.first : null;
      _quantityController.clear();
      _reasonController.clear();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogBatches = batches.where((b) => b.productId == _selectedProduct?.id).toList();

            return AlertDialog(
              title: const Text('New Disposal Request'),
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
                        items: products.map((p) {
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
                        const Text('No batches found for this product.', style: TextStyle(color: Colors.red, fontSize: 13))
                      else
                        DropdownButtonFormField<StockBatch>(
                          value: _selectedBatch,
                          items: dialogBatches.map((b) {
                            return DropdownMenuItem<StockBatch>(
                              value: b,
                              child: Text('${b.batchNumber} (Stock: ${b.quantity})'),
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

                      // Quantity to Discard
                      const Text('Quantity to Discard', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter quantity';
                          final qty = int.tryParse(v);
                          if (qty == null || qty <= 0) return 'Must be positive';
                          if (_selectedBatch != null && qty > _selectedBatch!.quantity) {
                            return 'Exceeds stock (${_selectedBatch!.quantity})';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'e.g., 20'),
                      ),
                      const SizedBox(height: 16),

                      // Reason
                      const Text('Reason / Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 2,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please explain the reason' : null,
                        decoration: const InputDecoration(hintText: 'Expired / damaged on arrival...'),
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
                          
                          final success = await controller.submitDisposal(
                            productId: _selectedProduct!.id,
                            batchId: _selectedBatch!.id,
                            quantity: int.parse(_quantityController.text),
                            reason: _reasonController.text.trim(),
                          );

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Disposal request submitted to Admin.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage ?? 'Failed to submit request.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: const Text('Submit Request'),
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
    final disposals = controller.disposals;
    final products = controller.products;
    final batches = controller.batches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Disposal & Damage Write-Off Requests',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showNewRequestDialog,
              icon: const Icon(Icons.delete_sweep_rounded),
              label: const Text('New Disposal Request'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: disposals.isEmpty
              ? const Card(
                  child: Center(
                    child: Text('No write-off requests submitted yet.'),
                  ),
                )
              : ListView.separated(
                  itemCount: disposals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = disposals[index];

                    final product = products.firstWhere(
                      (p) => p.id == item.productId,
                      orElse: () => Product(id: '', name: item.productName ?? 'Product', sku: '', price: 0, createdAt: DateTime.now()),
                    );
                    final batch = batches.firstWhere(
                      (b) => b.id == item.batchId,
                      orElse: () => StockBatch(id: '', productId: '', batchNumber: item.batchNumber ?? 'Unknown', quantity: 0, initialQuantity: 0, expiryDate: DateTime.now(), receivedDate: DateTime.now(), createdAt: DateTime.now()),
                    );

                    final displayProductName = (item.productName != null && item.productName != 'Product')
                        ? item.productName!
                        : product.name;
                    final displayBatchNumber = (item.batchNumber != null && item.batchNumber != 'Unknown')
                        ? item.batchNumber!
                        : batch.batchNumber;

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
                                    '$displayProductName (Batch: $displayBatchNumber)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reason: ${item.reason} | Submitted on: ${DateFormat('yyyy-MM-dd').format(item.createdAt)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.status.displayName,
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
