import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/features/auth/controllers/auth_controller.dart';
import 'package:may_snacks/models/profile.dart';
import 'package:may_snacks/services/auth_service.dart';

void main() {
  group('Authentication Flow Tests', () {
    late AuthService mockAuthService;
    late AuthController authController;

    setUp(() {
      mockAuthService = MockAuthService();
      authController = AuthController(mockAuthService);
    });

    tearDown(() {
      authController.dispose();
    });

    test('Initial State is not authenticated', () {
      expect(authController.isAuthenticated, isFalse);
      expect(authController.profile, isNull);
      expect(authController.isLoading, isFalse);
    });

    test('Admin logs in successfully without needing password reset', () async {
      final success = await authController.login('admin@maysnacks.com', 'admin123');
      expect(authController.errorMessage, isNull);
      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.profile?.role, UserRole.admin);
      expect(authController.needsPasswordReset, isFalse);
    });

    test('Sales Staff logs in successfully and requires forced password reset', () async {
      final success = await authController.login('sales@maysnacks.com', 'sales123');

      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.profile?.role, UserRole.salesStaff);
      expect(authController.needsPasswordReset, isTrue);
    });

    test('Forced password reset updates the profile and active status', () async {
      // 1. Log in as Sales Staff
      await authController.login('sales@maysnacks.com', 'sales123');
      expect(authController.needsPasswordReset, isTrue);

      // 2. Perform password update
      final resetSuccess = await authController.resetPassword('newSecurePassword123');
      expect(resetSuccess, isTrue);

      // 3. Flag should turn false and routing becomes active
      expect(authController.needsPasswordReset, isFalse);
      expect(authController.profile?.requiresPasswordReset, isFalse);
    });

    test('Sign out clears the authentication state', () async {
      await authController.login('admin@maysnacks.com', 'admin123');
      expect(authController.isAuthenticated, isTrue);

      await authController.logout();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.profile, isNull);
    });

    test('Admin can create a new staff account', () async {
      // Log in as Admin first
      await authController.login('admin@maysnacks.com', 'admin123');

      final newUserId = await authController.createStaffAccount(
        email: 'newstaff@maysnacks.com',
        password: 'defaultPass123',
        role: UserRole.warehouseManager,
        displayName: 'Aung Aung',
      );

      expect(newUserId, isNotNull);

      // Verify user list contains new user
      final allProfiles = await authController.fetchAllProfiles();
      final hasNewUser = allProfiles.any((p) => p.email == 'newstaff@maysnacks.com');
      expect(hasNewUser, isTrue);
    });
  });
}
