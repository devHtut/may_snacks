import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:may_snacks/models/profile.dart';
import 'package:may_snacks/features/auth/controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
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
                          
                          final authController = context.read<AuthController>();
                          final adminController = context.read<AdminController>();
                          
                          final userId = await authController.createStaffAccount(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                            role: selectedRole,
                            displayName: nameController.text.trim(),
                          );

                          setDialogState(() => dialogLoading = false);

                          if (userId != null && mounted) {
                            Navigator.pop(context);
                            adminController.loadAllAdminData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account successfully created for ${nameController.text}.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authController.errorMessage ?? 'Failed to create account.'),
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

                          final controller = context.read<AdminController>();
                          final success = await controller.resetStaffPassword(
                            user.id,
                            passwordController.text,
                          );

                          setDialogState(() => dialogLoading = false);

                          if (success && mounted) {
                            Navigator.pop(context);
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

  Future<void> _handleToggleStatus(UserProfile user, bool isActive) async {
    final controller = context.read<AdminController>();
    final success = await controller.toggleUserStatus(user.id, isActive);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.displayName} account status updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to toggle status.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AdminController>();
    final currentAdmin = context.watch<AuthController>().profile;
    final users = controller.users;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Staff & User Accounts Management',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showCreateUserDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Create Staff Account'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelf = user.id == currentAdmin?.id;

                    return Card(
                      margin: EdgeInsets.zero,
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: user.role == UserRole.warehouseManager
                                      ? Colors.blue[900]
                                      : user.role == UserRole.salesStaff
                                          ? Colors.teal[900]
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
                            Row(
                              children: [
                                if (user.requiresPasswordReset)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Pending Reset',
                                      style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                if (!user.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Deactivated',
                                      style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: isSelf
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Current User', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Reset Password Button
                                  OutlinedButton(
                                    onPressed: () => _showResetPasswordDialog(user),
                                    child: const Text('Reset Pass'),
                                  ),
                                  const SizedBox(width: 12),
                                  // Toggle Status Switch
                                  Switch(
                                    value: user.isActive,
                                    activeColor: theme.primaryColor,
                                    onChanged: (bool val) => _handleToggleStatus(user, val),
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
