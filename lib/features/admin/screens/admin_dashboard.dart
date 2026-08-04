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
              title: const Text('Create Staff Account'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      const Text('Name (Display Name)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
                        decoration: const InputDecoration(hintText: 'e.g., John Doe'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      const Text('Email Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter an email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'staff@maysnacks.com'),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text('Temporary Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: passwordController,
                        validator: (v) => v == null || v.isEmpty || v.length < 6 ? 'At least 6 characters' : null,
                        decoration: InputDecoration(
                          hintText: 'Temporary Password',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.copy_rounded),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: passwordController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Temporary password copied to clipboard.')),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      const Text('Role (User Role)'),
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
                  child: const Text('Cancel'),
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
                                content: Text('Account successfully created for ${nameController.text}.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage ?? 'Failed to create account.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: dialogLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Create Account'),
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
              title: Text('Reset Password for ${user.displayName}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Email: ${user.email}'),
                    const SizedBox(height: 16),
                    const Text('New Temporary Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      validator: (v) => v == null || v.isEmpty || v.length < 6 ? 'At least 6 characters' : null,
                      decoration: InputDecoration(
                        hintText: 'New Temporary Password',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: passwordController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New temporary password copied to clipboard.')),
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
                  child: const Text('Cancel'),
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
                                content: Text('New password generated. Forced reset status set.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage ?? 'Failed to reset password.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: dialogLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Reset Password'),
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
            tooltip: 'Logout',
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
                            'Welcome, ${adminProfile?.displayName ?? 'Admin'}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${adminProfile?.email ?? ''} | Role: Admin',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreateUserDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Create Account'),
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
                  'Staff Management & Passwords',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _fetching ? null : _loadProfiles,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh List',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profiles Table List
            Expanded(
              child: _fetching
                  ? const Center(child: CircularProgressIndicator())
                  : _profiles.isEmpty
                      ? const Center(child: Text('No staff accounts created yet.'))
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
                                              'Pending Password Reset',
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
                                              'Active',
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
                                        label: const Text('Reset Password'),
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
