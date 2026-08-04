import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/profile.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<UserProfile> _profiles = [];
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _fetching = true);
    final profiles = await context.read<AuthController>().fetchAllProfiles();
    setState(() {
      _profiles = profiles;
      _fetching = false;
    });
  }

  void _showCreateUserDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController(text: 'TempPass123!');
    UserRole selectedRole = UserRole.salesStaff;
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('အကောင့်သစ် ဖွင့်ပေးရန်'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      const Text('နာမည် (Display Name)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'နာမည် ဖြည့်စွက်ပါ' : null,
                        decoration: const InputDecoration(hintText: 'ဦးလှ / မစုစု'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      const Text('အီးမေးလ်လိပ်စာ (Email)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'အီးမေးလ် ဖြည့်စွက်ပါ';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                            return 'မှန်ကန်သော အီးမေးလ်ပုံစံ ဖြည့်သွင်းပါ';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'staff@maysnacks.com'),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text('ယာယီစကားဝှက် (Temporary Password)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: passwordController,
                        validator: (v) => v == null || v.isEmpty || v.length < 6 ? 'အနည်းဆုံး ၆ လုံး' : null,
                        decoration: InputDecoration(
                          hintText: 'ယာယီစကားဝှက်',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.copy_rounded),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: passwordController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ယာယီစကားဝှက်ကို Copy ကူးယူပြီးပါပြီ။')),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      const Text('ရာထူးအဆင့် (User Role)'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<UserRole>(
                        value: selectedRole,
                        decoration: const InputDecoration(),
                        items: [
                          DropdownMenuItem(
                            value: UserRole.salesStaff,
                            child: Text(UserRole.salesStaff.displayName),
                          ),
                          DropdownMenuItem(
                            value: UserRole.warehouseManager,
                            child: Text(UserRole.warehouseManager.displayName),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedRole = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading ? null : () => Navigator.pop(context),
                  child: const Text('မလုပ်တော့ပါ'),
                ),
                ElevatedButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => dialogLoading = true);
                          
                          final controller = context.read<AuthController>();
                          final userId = await controller.createStaffAccount(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                            role: selectedRole,
                            displayName: nameController.text.trim(),
                          );

                          setDialogState(() => dialogLoading = false);

                          if (userId != null && mounted) {
                            Navigator.pop(context);
                            _loadProfiles();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${nameController.text} အတွက် အကောင့်ဖွင့်လှစ်ခြင်း အောင်မြင်ပါသည်။'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage ?? 'အကောင့်ဖွင့်ရန် မအောင်မြင်ပါ။'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: dialogLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('အကောင့်ဖွင့်မည်'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetPasswordDialog(UserProfile user) {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController(text: 'ResetPass123!');
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${user.displayName} အတွက် စကားဝှက် ပြန်ထုတ်ရန်'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('အကောင့်အီးမေးလ်: ${user.email}'),
                    const SizedBox(height: 16),
                    const Text('ယာယီစကားဝှက်အသစ် (New Temp Password)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      validator: (v) => v == null || v.isEmpty || v.length < 6 ? 'အနည်းဆုံး ၆ လုံး' : null,
                      decoration: InputDecoration(
                        hintText: 'ယာယီစကားဝှက်အသစ်',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: passwordController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ယာယီစကားဝှက်အသစ်ကို Copy ကူးယူပြီးပါပြီ။')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading ? null : () => Navigator.pop(context),
                  child: const Text('မလုပ်တော့ပါ'),
                ),
                ElevatedButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => dialogLoading = true);

                          final controller = context.read<AuthController>();
                          final success = await controller.forceResetStaffPassword(
                            user.id,
                            passwordController.text,
                          );

                          setDialogState(() => dialogLoading = false);

                          if (success && mounted) {
                            Navigator.pop(context);
                            _loadProfiles();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('စကားဝှက်အသစ် ပြန်ထုတ်ပေးခြင်း အောင်မြင်ပြီး ယာယီစကားဝှက်အခြေအနေ ပြောင်းလိုက်ပါပြီ။'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage ?? 'စကားဝှက် ပြောင်းလဲရန် မအောင်မြင်ပါ။'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: dialogLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('စကားဝှက်အသစ်သတ်မှတ်မည်'),
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
    final adminProfile = context.watch<AuthController>().profile;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'May Snacks - Admin Panel',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'အကောင့်ထွက်မည်',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats & greeting card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, size: 36, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'မင်္ဂလာပါ၊ ${adminProfile?.displayName ?? 'Admin'}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'အီးမေးလ်: ${adminProfile?.email ?? ''} | အဆင့်အတန်း: Admin (စီမံခန့်ခွဲသူ)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreateUserDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('အကောင့်အသစ်ဖွင့်ရန်'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Staff List header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ဝန်ထမ်းစာရင်းနှင့် စကားဝှက် စီမံခန့်ခွဲမှု',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _fetching ? null : _loadProfiles,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'စာရင်းပြန်ခေါ်မည်',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profiles Table List
            Expanded(
              child: _fetching
                  ? const Center(child: CircularProgressIndicator())
                  : _profiles.isEmpty
                      ? const Center(child: Text('အကောင့်ဖွင့်ထားသော ဝန်ထမ်းများ မရှိသေးပါ။'))
                      : ListView.separated(
                          itemCount: _profiles.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = _profiles[index];
                            final isUserAdmin = user.role == UserRole.admin;

                            return Card(
                              color: theme.brightness == Brightness.dark
                                  ? theme.cardColor
                                  : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: user.role == UserRole.warehouseManager
                                      ? Colors.blue.withOpacity(0.1)
                                      : user.role == UserRole.salesStaff
                                          ? Colors.teal.withOpacity(0.1)
                                          : Colors.amber.withOpacity(0.1),
                                  child: Icon(
                                    user.role == UserRole.warehouseManager
                                        ? Icons.warehouse_rounded
                                        : user.role == UserRole.salesStaff
                                            ? Icons.directions_bike_rounded
                                            : Icons.security_rounded,
                                    color: user.role == UserRole.warehouseManager
                                        ? Colors.blue
                                        : user.role == UserRole.salesStaff
                                            ? Colors.teal
                                            : Colors.amber[900],
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      user.displayName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: user.role == UserRole.warehouseManager
                                            ? Colors.blue.withOpacity(0.15)
                                            : user.role == UserRole.salesStaff
                                                ? Colors.teal.withOpacity(0.15)
                                                : Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        user.role.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: user.role == UserRole.warehouseManager
                                              ? Colors.blue[900] ?? Colors.blue
                                              : user.role == UserRole.salesStaff
                                                  ? Colors.teal[900] ?? Colors.teal
                                                  : Colors.amber[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Email: ${user.email}'),
                                    const SizedBox(height: 6),
                                    // Status badges
                                    if (user.requiresPasswordReset)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                                            SizedBox(width: 4),
                                            Text(
                                              'စကားဝှက် Reset လုပ်ရန် လိုအပ်ဆဲဖြစ်သည် (Pending Reset)',
                                              style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
                                            SizedBox(width: 4),
                                            Text(
                                              'အကောင့်အသုံးပြုနိုင်ပါပြီ (Active)',
                                              style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: isUserAdmin
                                    ? null
                                    : OutlinedButton.icon(
                                        onPressed: () => _showResetPasswordDialog(user),
                                        icon: const Icon(Icons.lock_reset_rounded, size: 18),
                                        label: const Text('စကားဝှက်အသစ်သတ်မှတ်'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: theme.primaryColor,
                                          side: BorderSide(color: theme.primaryColor),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
