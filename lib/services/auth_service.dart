import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/profile.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
abstract class AuthService {
  UserProfile? get currentUserProfile;
  Stream<UserProfile?> get onProfileChanged;
  
  Future<UserProfile?> signIn(String email, String password);
  Future<void> signOut();
  Future<void> updatePassword(String newPassword);
  Future<UserProfile?> getProfile(String userId);
  Future<String> createStaffUser(String email, String password, UserRole role, String displayName);
  Future<void> resetStaffPassword(String targetUserId, String newPassword);
  Future<void> toggleUserStatus(String targetUserId, bool isActive);
  Future<List<UserProfile>> getAllProfiles();
  
  void dispose();
}

class SupabaseAuthService implements AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  UserProfile? _currentProfile;
  final _profileController = StreamController<UserProfile?>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;

  SupabaseAuthService() {
    _initSession();

    // Listen for auth changes to load the profile automatically
    _authSubscription = _client.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;
      if (user == null) {
        await ProfileCache.clear();
        _updateProfile(null);
      } else {
        try {
          final profile = await getProfile(user.id);
          if (profile != null) {
            await ProfileCache.save(profile);
            _updateProfile(profile);
          } else {
            throw Exception('Profile not found');
          }
        } catch (e) {
          // Check for offline cached profile first
          final cachedProfile = await ProfileCache.load();
          if (cachedProfile != null && cachedProfile.id == user.id) {
            _updateProfile(cachedProfile);
          } else {
            // Fallback for missing profile cache when offline
            _updateProfile(UserProfile(
              id: user.id,
              email: user.email ?? '',
              role: UserRole.salesStaff,
              displayName: user.userMetadata?['display_name'] ?? '',
              requiresPasswordReset: user.userMetadata?['requires_password_reset'] as bool? ?? false,
            ));
          }
        }
      }
    });
  }

  Future<void> _initSession() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      final cachedProfile = await ProfileCache.load();
      if (cachedProfile != null && cachedProfile.id == user.id && _currentProfile == null) {
        _updateProfile(cachedProfile);
      }
    }
  }

  void _updateProfile(UserProfile? profile) {
    _currentProfile = profile;
    _profileController.add(profile);
  }

  @override
  UserProfile? get currentUserProfile => _currentProfile;

  @override
  Stream<UserProfile?> get onProfileChanged => _profileController.stream;

  @override
  Future<UserProfile?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) return null;
    final profile = await getProfile(response.user!.id);
    
    // Check if the user account is active
    if (profile == null || !profile.isActive) {
      await ProfileCache.clear();
      await _client.auth.signOut();
      throw Exception('This account has been deactivated. Please contact support.');
    }
    
    await ProfileCache.save(profile);
    _updateProfile(profile);
    return profile;
  }

  @override
  Future<void> signOut() async {
    await ProfileCache.clear();
    await _client.auth.signOut();
    _updateProfile(null);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No logged in user.');
    
    // 1. Update Password in Supabase Auth
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    
    // 2. Update requires_password_reset flag in public profiles
    await _client.from('profiles').update({
      'requires_password_reset': false,
    }).eq('id', user.id);
    
    // Refresh the profile locally
    final updatedProfile = await getProfile(user.id);
    if (updatedProfile != null) {
      await ProfileCache.save(updatedProfile);
      _updateProfile(updatedProfile);
    }
  }


  @override
  Future<UserProfile?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }

  @override
  Future<String> createStaffUser(
    String email,
    String password,
    UserRole role,
    String displayName,
  ) async {
    // Call the RPC defined in our SQL schema
    final response = await _client.rpc('create_staff_user', params: {
      'user_email': email,
      'user_password': password,
      'user_role': role.key,
      'user_display_name': displayName,
    });
    return response as String;
  }

  @override
  Future<void> resetStaffPassword(String targetUserId, String newPassword) async {
    // Call the RPC defined in our SQL schema
    await _client.rpc('reset_staff_password', params: {
      'target_user_id': targetUserId,
      'new_password': newPassword,
    });
  }

  @override
  Future<void> toggleUserStatus(String targetUserId, bool isActive) async {
    await _client.rpc('toggle_user_status', params: {
      'target_user_id': targetUserId,
      'status': isActive,
    });
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    final response = await _client.from('profiles').select().order('created_at');
    return (response as List).map((json) => UserProfile.fromJson(json)).toList();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileController.close();
  }
}

// Offline Developer fallback to test the complete Auth flow without Supabase configured
class MockAuthService implements AuthService {
  UserProfile? _currentProfile;
  final _profileController = StreamController<UserProfile?>.broadcast();

  MockAuthService() {
    _initMockSession();
  }

  Future<void> _initMockSession() async {
    final cached = await ProfileCache.load();
    if (cached != null) {
      _updateProfile(cached);
    }
  }

  // In-memory data store for testing
  final List<UserProfile> _mockProfiles = [
    UserProfile(
      id: 'mock-admin-id',
      email: 'admin@maysnacks.com',
      role: UserRole.admin,
      displayName: 'Ko Myo (Admin)',
      requiresPasswordReset: false,
    ),
    UserProfile(
      id: 'mock-warehouse-id',
      email: 'warehouse@maysnacks.com',
      role: UserRole.warehouseManager,
      displayName: 'Ko Hla (Warehouse Manager)',
      requiresPasswordReset: true, // Needs default password reset
    ),
    UserProfile(
      id: 'mock-sales-id',
      email: 'sales@maysnacks.com',
      role: UserRole.salesStaff,
      displayName: 'Ma Su (Sales Staff)',
      requiresPasswordReset: true, // Needs default password reset
    ),
  ];

  // Map to store credentials: { email: password }
  final Map<String, String> _mockPasswords = {
    'admin@maysnacks.com': 'admin123',
    'warehouse@maysnacks.com': 'warehouse123',
    'sales@maysnacks.com': 'sales123',
  };

  void _updateProfile(UserProfile? profile) {
    _currentProfile = profile;
    _profileController.add(profile);
  }

  @override
  UserProfile? get currentUserProfile => _currentProfile;

  @override
  Stream<UserProfile?> get onProfileChanged => _profileController.stream;

  @override
  Future<UserProfile?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network latency

    final index = _mockProfiles.indexWhere((p) => p.email.toLowerCase() == email.toLowerCase());
    if (index == -1) {
      throw Exception('Invalid email or password.');
    }

    final realPassword = _mockPasswords[email.toLowerCase()];
    if (realPassword != password) {
      throw Exception('Invalid email or password.');
    }

    final profile = _mockProfiles[index];
    
    // Check if the user account is active
    if (!profile.isActive) {
      await ProfileCache.clear();
      throw Exception('This account has been deactivated. Please contact support.');
    }
    
    await ProfileCache.save(profile);
    _updateProfile(profile);
    return profile;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await ProfileCache.clear();
    _updateProfile(null);
  }


  @override
  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentProfile == null) throw Exception('No logged in user.');

    // Update in memory database
    final index = _mockProfiles.indexWhere((p) => p.id == _currentProfile!.id);
    if (index != -1) {
      final updated = _mockProfiles[index].copyWith(requiresPasswordReset: false);
      _mockProfiles[index] = updated;
      _mockPasswords[updated.email.toLowerCase()] = newPassword;
      await ProfileCache.save(updated);
      _updateProfile(updated);
    }
  }

  @override
  Future<UserProfile?> getProfile(String userId) async {
    return _mockProfiles.firstWhere((p) => p.id == userId);
  }

  @override
  Future<String> createStaffUser(
    String email,
    String password,
    UserRole role,
    String displayName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (_mockPasswords.containsKey(email.toLowerCase())) {
      throw Exception('A user with this email already exists.');
    }

    final newId = 'mock-user-${DateTime.now().millisecondsSinceEpoch}';
    final profile = UserProfile(
      id: newId,
      email: email,
      role: role,
      displayName: displayName,
      requiresPasswordReset: true,
    );

    _mockProfiles.add(profile);
    _mockPasswords[email.toLowerCase()] = password;
    return newId;
  }

  @override
  Future<void> resetStaffPassword(String targetUserId, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockProfiles.indexWhere((p) => p.id == targetUserId);
    if (index == -1) throw Exception('User not found.');

    final profile = _mockProfiles[index];
    _mockProfiles[index] = profile.copyWith(requiresPasswordReset: true);
    _mockPasswords[profile.email.toLowerCase()] = newPassword;
  }

  @override
  Future<void> toggleUserStatus(String targetUserId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockProfiles.indexWhere((p) => p.id == targetUserId);
    if (index != -1) {
      _mockProfiles[index] = _mockProfiles[index].copyWith(isActive: isActive);
    }
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockProfiles);
  }

  @override
  void dispose() {
    _profileController.close();
  }
}

class AuthServiceFactory {
  static AuthService create() {
    if (SupabaseConfig.useMock) {
      return MockAuthService();
    } else {
      return SupabaseAuthService();
    }
  }
}

class ProfileCache {
  static Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/cached_user_profile.json');
  }

  static Future<void> save(UserProfile profile) async {
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  static Future<UserProfile?> load() async {
    try {
      final f = await _file;
      if (await f.exists()) {
        final content = await f.readAsString();
        return UserProfile.fromJson(jsonDecode(content));
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clear() async {
    try {
      final f = await _file;
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
  }
}

