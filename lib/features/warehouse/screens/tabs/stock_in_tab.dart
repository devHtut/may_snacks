import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class StockInTab extends StatefulWidget {
  const StockInTab({super.key});

  @override
  State<StockInTab> createState() => _StockInTabState();
}

class _StockInTabState extends State<StockInTab> {
  final _formKey = GlobalKey<FormState>();
  final _batchNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  
  Product? _selectedProduct;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _generateBatchNumber();
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _generateBatchNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final randomStr = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    _batchNumberController.text = 'BAT-$dateStr-$randomStr';
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(), // Stock must not be already expired on arrival
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _handleStockIn() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null || _selectedExpiryDate == null) {
      if (_selectedExpiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an expiry date.')),
        );
      }
      return;
    }

    final controller = context.read<WarehouseController>();
    final success = await controller.stockIn(
      productId: _selectedProduct!.id,
      batchNumber: _batchNumberController.text.trim(),
      quantity: int.parse(_quantityController.text),
      expiryDate: _selectedExpiryDate!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock batch successfully added.'),
          backgroundColor: Colors.green,
        ),
      );
      // Reset form fields
      setState(() {
        _quantityController.clear();
        _selectedExpiryDate = null;
        _generateBatchNumber();
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to log stock batch.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<WarehouseController>();
    final products = controller.products;
    final isLoading = controller.isLoading;

    if (products.isEmpty) {
      return const Center(child: Text('No products available. Please load database.'));
    }

    if (_selectedProduct != null && products.any((p) => p.id == _selectedProduct!.id)) {
      _selectedProduct = products.firstWhere((p) => p.id == _selectedProduct!.id);
    } else {
      _selectedProduct = products.isNotEmpty ? products.first : null;
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.add_business_rounded, color: theme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Stock In (New Batch Entry)',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Choose Product
                    Text(
                      'Select Product',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      items: products.map<DropdownMenuItem<Product>>((product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: (Product? value) {
                        if (value != null) {
                          setState(() => _selectedProduct = value);
                        }
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Batch Number
                    Text(
                      'Batch Number',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _batchNumberController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a batch number' : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.tag_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.autorenew_rounded),
                          tooltip: 'Regenerate Batch ID',
                          onPressed: _generateBatchNumber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quantity & Expiry Date row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Received Quantity',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter quantity';
                                  final num = int.tryParse(value);
                                  if (num == null || num <= 0) return 'Must be positive';
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'e.g., 100',
                                  prefixIcon: Icon(Icons.onetwothree_rounded),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expiry Date',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectExpiryDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_outlined, size: 20, color: theme.primaryColor),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedExpiryDate == null
                                            ? 'Select Date'
                                            : DateFormat('yyyy-MM-dd').format(_selectedExpiryDate!),
                                        style: TextStyle(
                                          color: _selectedExpiryDate == null ? Colors.grey : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleStockIn,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save Stock Entry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
