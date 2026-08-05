import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/services/location_service.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class CustomerManagementTab extends StatefulWidget {
  const CustomerManagementTab({super.key});

  @override
  State<CustomerManagementTab> createState() => _CustomerManagementTabState();
}

class _CustomerManagementTabState extends State<CustomerManagementTab> {
  String _searchQuery = '';
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, List<String>> _locationData = {};

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final data = await LocationService.loadLocationData();
    if (mounted) {
      setState(() {
        _locationData = data;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();

    String? selectedRegion;
    String? selectedTownship;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final regions = LocationService.getRegions(_locationData);
            final townships = LocationService.getTownships(_locationData, selectedRegion);

            return AlertDialog(
              title: const Text('Add Official Customer Store'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Store name is required' : null,
                        decoration: const InputDecoration(
                          labelText: 'Store Name *',
                          hintText: 'e.g., City Mart Junction City',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRegion,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Region / State *'),
                        validator: (v) => v == null ? 'Please select Region / State' : null,
                        items: regions.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedRegion = val;
                            selectedTownship = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedTownship,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Township *'),
                        validator: (v) => v == null ? 'Please select Township' : null,
                        items: townships.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedTownship = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: 'e.g., 09123456789',
                          counterText: '',
                          prefixIcon: Icon(Icons.phone_android_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          final trimmed = v.trim();
                          if (!trimmed.startsWith('09')) {
                            return 'Phone number must start with 09';
                          }
                          if (trimmed.length < 9) {
                            return 'Must be at least 9 digits long (e.g. 09xxxxxxx)';
                          }
                          if (trimmed.length > 11) {
                            return 'Cannot exceed 11 digits';
                          }
                          if (!RegExp(r'^09\d{7,9}$').hasMatch(trimmed)) {
                            return 'Only numbers are allowed starting with 09';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Street Address (Optional)',
                          hintText: 'e.g., Pyay Road, Dagon Township',
                        ),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final controller = context.read<WarehouseController>();
                      final success = await controller.addCustomerDirect(
                        name: _nameController.text.trim(),
                        region: selectedRegion!,
                        township: selectedTownship!,
                        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                        phone: _phoneController.text.trim(),
                      );
                      if (success && mounted) {
                        Navigator.pop(context);
                        _nameController.clear();
                        _addressController.clear();
                        _phoneController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New customer store added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add Store'),
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
    final pendingCustomers = controller.pendingCustomers;
    final approvedCustomers = controller.approvedCustomers;

    final filteredApproved = approvedCustomers.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.region.toLowerCase().contains(query) ||
          c.township.toLowerCase().contains(query) ||
          (c.address?.toLowerCase().contains(query) ?? false) ||
          c.phone.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Stores Master Management',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddCustomerDialog,
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Add Official Store'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pending Requests Section
          Card(
            color: Colors.orange.withOpacity(0.05),
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.orange.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        'Pending Field Store Registrations (${pendingCustomers.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pendingCustomers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No pending store requests from field sales staff.'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingCustomers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = pendingCustomers[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Location: ${customer.township}, ${customer.region}\nAddress: ${customer.address ?? 'N/A'} | Phone: ${customer.phone}\nRequested on: ${DateFormat('yyyy-MM-dd HH:mm').format(customer.createdAt)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                onPressed: () async {
                                  final success = await controller.rejectCustomer(customer.id);
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Store registration request rejected.')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.close_rounded, size: 18),
                                label: const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  final success = await controller.approveCustomer(customer.id);
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Store approved and added to master dropdown!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check_rounded, size: 18),
                                label: const Text('Approve'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Approved Master Customers List
          Text(
            'Approved Master Stores List (${approvedCustomers.length})',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search stores by name, region, township, address, or phone...',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 16),
          filteredApproved.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No approved customer stores found.')),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredApproved.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final store = filteredApproved[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.storefront_rounded, color: theme.primaryColor),
                        ),
                        title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Location: ${store.township}, ${store.region}\nAddress: ${store.address ?? 'N/A'} | Phone: ${store.phone}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active Master Store',
                            style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
