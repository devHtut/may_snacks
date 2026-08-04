import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/profile.dart';
import '../../../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  
  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserProfile?>? _profileSubscription;

  UserProfile? get profile => _profile;
  bool get isAuthenticated => _profile != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Convenient checks
  bool get needsPasswordReset => _profile != null && _profile!.requiresPasswordReset;
  UserRole? get currentRole => _profile?.role;

  AuthController(this._authService) {
    _profile = _authService.currentUserProfile;
    _profileSubscription = _authService.onProfileChanged.listen((profile) {
      _profile = profile;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = await _authService.signIn(email, password);
      if (userProfile != null) {
        _profile = userProfile;
      }
      _isLoading = false;
      notifyListeners();
      return userProfile != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _profile = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    if (!_authService.useMockAndPasswordChecks(newPassword)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updatePassword(newPassword);
      _profile = _authService.currentUserProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<String?> createStaffAccount({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _authService.createStaffUser(email, password, role, displayName);
      _isLoading = false;
      return userId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> forceResetStaffPassword(String targetUserId, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetStaffPassword(targetUserId, newPassword);
      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<List<UserProfile>> fetchAllProfiles() async {
    try {
      return await _authService.getAllProfiles();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return [];
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}

extension on AuthService {
  bool useMockAndPasswordChecks(String password) {
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }
    return true;
  }
}
