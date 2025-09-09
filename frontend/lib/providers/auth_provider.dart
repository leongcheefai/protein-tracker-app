import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/service_locator.dart';
import '../services/auth_service.dart';
import '../models/api_response.dart';
import '../models/dto/user_profile_dto.dart';

enum AuthenticationState {
  unknown,
  unauthenticated,
  authenticating,
  authenticated,
}

enum AuthMethod {
  email,
  google,
  apple,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = ServiceLocator().authService;
  
  AuthenticationState _state = AuthenticationState.unknown;
  UserProfileDto? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthenticationState get state => _state;
  UserProfileDto? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthenticationState.authenticated;
  bool get isUnauthenticated => _state == AuthenticationState.unauthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check if user is already authenticated
      final supabaseUser = _authService.currentUser;
      if (supabaseUser != null) {
        // Try to load existing backend token and verify
        await _authService.refreshToken();
        
        // If token refresh succeeds, get user profile
        final profileResponse = await ServiceLocator().userService.getProfile();
        if (profileResponse.success && profileResponse.data != null) {
          _currentUser = profileResponse.data;
          _setState(AuthenticationState.authenticated);
        } else {
          // Token invalid or profile not found, sign out
          await _signOutInternal();
        }
      } else {
        _setState(AuthenticationState.unauthenticated);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _setState(AuthenticationState.unauthenticated);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    return await _performAuth(() async {
      final response = await _authService.signInWithEmail(email, password);
      return response;
    });
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    return await _performAuth(() async {
      final response = await _authService.signUpWithEmail(email, password);
      return response;
    });
  }

  Future<bool> signInWithGoogle() async {
    return await _performAuth(() async {
      final response = await _authService.signInWithGoogle();
      return response;
    });
  }

  Future<bool> signInWithApple() async {
    return await _performAuth(() async {
      final response = await _authService.signInWithApple();
      return response;
    });
  }

  Future<bool> _performAuth(Future<ApiResponse<UserProfileDto>> Function() authFunction) async {
    try {
      print('🔄 Auth Provider: Starting authentication...');
      _setLoading(true);
      _clearError();
      _setState(AuthenticationState.authenticating);

      final response = await authFunction();
      
      if (response.success && response.data != null) {
        print('✅ Auth Provider: Authentication successful, user: ${response.data?.email}');
        print('✅ Auth Provider: User has complete profile: ${response.data?.displayName != null && response.data?.age != null && response.data?.weight != null && response.data?.height != null && response.data?.dailyProteinGoal != null}');
        
        // Check if this is an email verification pending case
        if (response.message?.contains('verification') == true || response.message?.contains('check your email') == true) {
          // Email verification required - show message but don't authenticate yet
          _setError(response.message!);
          _setState(AuthenticationState.unauthenticated);
          _setLoading(false);
          return false;
        }
        
        _currentUser = response.data;
        _setState(AuthenticationState.authenticated);
        _setLoading(false);
        return true;
      } else {
        print('❌ Auth Provider: Authentication failed: ${response.error?.message}');
        _setError(response.error?.message ?? 'Authentication failed');
        _setState(AuthenticationState.unauthenticated);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Auth Provider: Authentication error: ${e.toString()}');
      _setError(e.toString());
      _setState(AuthenticationState.unauthenticated);
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _signOutInternal();
    } catch (e) {
      debugPrint('Sign out error: $e');
      // Still clear local state even if server call fails
      await _signOutInternal();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signOutInternal() async {
    await _authService.signOut();
    _currentUser = null;
    _setState(AuthenticationState.unauthenticated);
  }

  Future<bool> refreshUserProfile() async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      final response = await ServiceLocator().userService.getProfile();
      
      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to refresh user profile');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile(UserProfileDto updatedProfile) async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      final response = await ServiceLocator().userService.updateProfile(updatedProfile);
      
      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      final response = await ServiceLocator().userService.deleteAccount();
      
      if (response.success) {
        await _signOutInternal();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to delete account');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Listen to Supabase auth state changes
  void startAuthStateListener() {
    _authService.authStateChanges.listen((AuthState authState) async {
      final user = authState.session?.user;
      if (user == null && isAuthenticated) {
        // User signed out externally, update our state
        await _signOutInternal();
      } else if (user != null && !isAuthenticated && _state != AuthenticationState.authenticating) {
        // User signed in externally, try to get profile
        try {
          final response = await ServiceLocator().userService.getProfile();
          if (response.success && response.data != null) {
            _currentUser = response.data;
            _setState(AuthenticationState.authenticated);
          }
        } catch (e) {
          debugPrint('External auth state change error: $e');
        }
      }
    });
  }

  void _setState(AuthenticationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }

  // Helper methods for UI
  String get displayName {
    return _currentUser?.displayName ?? 
           _currentUser?.email ?? 
           'User';
  }

  String? get userEmail {
    return _currentUser?.email;
  }

  bool get hasCompleteProfile {
    if (_currentUser == null) return false;
    return _currentUser!.displayName != null &&
           _currentUser!.age != null &&
           _currentUser!.weight != null &&
           _currentUser!.height != null &&
           _currentUser!.dailyProteinGoal != null;
  }

  // Quick access to common profile data
  double? get dailyProteinGoal => _currentUser?.dailyProteinGoal;
  double? get weight => _currentUser?.weight;
  double? get height => _currentUser?.height;
  int? get age => _currentUser?.age;
  String? get activityLevel => _currentUser?.activityLevel;
  List<String>? get dietaryRestrictions => _currentUser?.dietaryRestrictions;
}