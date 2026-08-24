import 'package:flutter/material.dart';
import '../../../common/utils/error_handler.dart';
import '../../../models/profile.dart';
import '../../../models/audit_log.dart';
import '../../../services/admin_service.dart';
import '../../../services/auth_service.dart';

class AdminController extends ChangeNotifier {
  final AdminService _adminService;
  final AuthService _authService;

  List<UserProfile> _users = [];
  List<AuditLog> _auditLogs = [];
  Map<String, dynamic> _analytics = {
    'totalRevenue': 0.0,
    'salesByProduct': <String, double>{},
    'salesByStaff': <String, double>{},
    'ordersCount': 0,
  };

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedDurationFilter = 'month';

  AdminController(this._adminService, this._authService);

  List<UserProfile> get users => _users;
  List<AuditLog> get auditLogs => _auditLogs;
  Map<String, dynamic> get analytics => _analytics;
  String get selectedDurationFilter => _selectedDurationFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _authService.getAllProfiles(),
        _adminService.fetchAuditLogs(),
        _adminService.fetchSalesAnalytics(duration: _selectedDurationFilter),
      ]);

      _users = results[0] as List<UserProfile>;
      _auditLogs = results[1] as List<AuditLog>;
      _analytics = results[2] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDurationFilter(String duration) async {
    _selectedDurationFilter = duration;
    notifyListeners();
    try {
      final updatedAnalytics = await _adminService.fetchSalesAnalytics(duration: duration);
      _analytics = updatedAnalytics;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
    } finally {
      notifyListeners();
    }
  }

  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.toggleUserStatus(userId, isActive);
      // Update local state
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isActive: isActive);
      }
      
      final actionText = isActive ? 'ACTIVATED' : 'DEACTIVATED';
      await _adminService.logEvent('USER_STATUS_CHANGED', 'User (ID: $userId) was $actionText by Admin.');
      
      // Reload audit logs
      _auditLogs = await _adminService.fetchAuditLogs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct({
    required String name,
    required String sku,
    required double price,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.addProduct(name, sku, price);
      // Reload audit logs and data
      _auditLogs = await _adminService.fetchAuditLogs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductPrice(String productId, double newPrice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.updateProductPrice(productId, newPrice);
      // Reload audit logs and data
      _auditLogs = await _adminService.fetchAuditLogs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.deleteProduct(productId);
      _auditLogs = await _adminService.fetchAuditLogs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveDisposalRequest(String disposalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.approveDisposal(disposalId);
      // Reload everything to get updated audit logs, balances, and analytics
      await loadAllAdminData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectDisposalRequest(String disposalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.rejectDisposal(disposalId);
      // Reload everything to get updated data
      await loadAllAdminData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetStaffPassword(String targetUserId, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetStaffPassword(targetUserId, newPassword);
      // Update local profiles list
      final idx = _users.indexWhere((u) => u.id == targetUserId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(requiresPasswordReset: true);
      }
      
      await _adminService.logEvent('PASSWORD_RESET', 'Admin forced password reset for user (ID: $targetUserId).');
      _auditLogs = await _adminService.fetchAuditLogs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
