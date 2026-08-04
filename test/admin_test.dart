import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/models/disposal.dart';
import 'package:may_snacks/services/auth_service.dart';
import 'package:may_snacks/services/admin_service.dart';
import 'package:may_snacks/services/warehouse_service.dart';

void main() {
  group('Admin Dashboard & Control Services Tests', () {
    late AuthService authService;
    late AdminService adminService;

    setUp(() {
      // Reinitialize mock databases to default values
      MockWarehouseService.resetDatabase();
      
      authService = MockAuthService();
      adminService = MockAdminService();
    });

    test('Toggling user status block and unblock sign-in', () async {
      // 1. Initial State: warehouse manager can sign in successfully
      final initialProfile = await authService.signIn('warehouse@maysnacks.com', 'warehouse123');
      expect(initialProfile, isNotNull);
      expect(initialProfile!.isActive, isTrue);

      await authService.signOut();

      // 2. Admin deactivates warehouse manager
      await authService.toggleUserStatus(initialProfile.id, false);

      // 3. Try to sign in as deactivated manager -> should throw Exception
      await expectLater(
        authService.signIn('warehouse@maysnacks.com', 'warehouse123'),
        throwsException,
      );

      // 4. Admin re-enables warehouse manager
      await authService.toggleUserStatus(initialProfile.id, true);

      // 5. Try signing in again -> should succeed
      final finalProfile = await authService.signIn('warehouse@maysnacks.com', 'warehouse123');
      expect(finalProfile, isNotNull);
      expect(finalProfile!.isActive, isTrue);
    });

    test('Admin approvals successfully process disposals and log system audits', () async {
      // 1. Submit a disposal request as Warehouse Manager
      final initialLogsCount = (await adminService.fetchAuditLogs()).length;

      final disposal = await MockWarehouseService().submitDisposalRequest(
        productId: 'p1',
        batchId: 'b1',
        quantity: 20,
        reason: 'Expired product batch',
      );

      expect(disposal.status, equals(DisposalStatus.pending));

      // 2. Fulfill approval via Admin Service
      await adminService.approveDisposal(disposal.id);

      // 3. Check that disposal status is approved and batch quantity has been deducted
      final updatedDisposals = MockWarehouseService.disposalsList;
      final approvedDisposal = updatedDisposals.firstWhere((d) => d.id == disposal.id);
      expect(approvedDisposal.status, equals(DisposalStatus.approved));

      final batches = MockWarehouseService.batchesList;
      final targetBatch = batches.firstWhere((b) => b.id == 'b1');
      expect(targetBatch.quantity, equals(30)); // Initial 50 - 20 = 30 units

      // 4. Verify system log audit is generated
      final logs = await adminService.fetchAuditLogs();
      expect(logs.length, equals(initialLogsCount + 1));
      expect(logs.first.action, equals('DISPOSAL_APPROVED'));
    });
  });
}
