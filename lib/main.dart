import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'core/theme.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/password_reset_screen.dart';
import 'features/sales/screens/sales_dashboard.dart';
import 'features/warehouse/screens/warehouse_dashboard.dart';
import 'models/profile.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase only if we are not running in mock mode
  if (!SupabaseConfig.useMock) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      // In case initialization fails, print error. The developer can fix credentials.
      debugPrint('Supabase Initialization Error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the main auth service (decides Mock vs Real via SupabaseConfig)
        Provider<AuthService>(
          create: (_) => AuthServiceFactory.create(),
          dispose: (_, service) => service.dispose(),
        ),
        // Provide the auth controller which depends on AuthService
        ChangeNotifierProxyProvider<AuthService, AuthController>(
          create: (context) => AuthController(context.read<AuthService>()),
          update: (context, service, controller) =>
              controller ?? AuthController(service),
        ),
      ],
      child: MaterialApp(
        title: 'May Snacks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Support system light/dark settings
        home: const RootNavigationRouter(),
      ),
    );
  }
}

/// Dynamic Navigation Router listening to changes in AuthController.
/// Automatically handles redirection to:
/// 1. LoginScreen (Not authenticated)
/// 2. PasswordResetScreen (Needs to reset default/temporary password)
/// 3. Respective role dashboard (Active accounts)
class RootNavigationRouter extends StatelessWidget {
  const RootNavigationRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    // 1. Not Authenticated -> Show Login Page
    if (!authController.isAuthenticated) {
      return const LoginScreen();
    }

    // 2. Authenticated but needs password reset -> Show Reset Screen
    if (authController.needsPasswordReset) {
      return const PasswordResetScreen();
    }

    // 3. Authenticated and password reset is complete -> Dashboard by role
    switch (authController.currentRole) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.warehouseManager:
        return const WarehouseDashboard();
      case UserRole.salesStaff:
      default:
        return const SalesDashboard();
    }
  }
}
