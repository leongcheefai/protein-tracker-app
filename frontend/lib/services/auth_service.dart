import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'api_service.dart';
import '../models/api_response.dart';
import '../models/dto/user_profile_dto.dart';

class AuthService {
  final ApiService _apiService;
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._apiService);

  Future<ApiResponse<UserProfileDto>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      // Sign in with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Sign in failed'),
        );
      }

      // Get Supabase access token
      final accessToken = response.session?.accessToken;
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend and get user profile
      return await _verifyTokenWithBackend(accessToken);
    } on AuthException catch (e) {
      return ApiResponse.error(
        ApiError.authentication(e.message),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError.authentication(e.toString()),
      );
    }
  }

  Future<ApiResponse<UserProfileDto>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      // Create user with Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Sign up failed'),
        );
      }

      // Get Supabase access token
      final accessToken = response.session?.accessToken;
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend and create user profile
      return await _verifyTokenWithBackend(accessToken);
    } on AuthException catch (e) {
      return ApiResponse.error(
        ApiError.authentication(e.message),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError.authentication(e.toString()),
      );
    }
  }

  Future<ApiResponse<UserProfileDto>> signInWithGoogle() async {
    try {
      // Sign out from previous session
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return ApiResponse.error(
          ApiError.authentication('Google sign in cancelled'),
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get Google tokens'),
        );
      }

      // Sign in to Supabase with Google credential
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Google sign in failed'),
        );
      }

      // Get Supabase access token
      final accessToken = response.session?.accessToken;
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend
      return await _verifyTokenWithBackend(accessToken);
    } catch (e) {
      return ApiResponse.error(
        ApiError.authentication('Google sign in error: ${e.toString()}'),
      );
    }
  }

  Future<ApiResponse<UserProfileDto>> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get Apple ID token'),
        );
      }

      // Sign in to Supabase with Apple credential
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
      );

      if (response.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Apple sign in failed'),
        );
      }

      // Get Supabase access token
      final accessToken = response.session?.accessToken;
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend
      return await _verifyTokenWithBackend(accessToken);
    } catch (e) {
      return ApiResponse.error(
        ApiError.authentication('Apple sign in error: ${e.toString()}'),
      );
    }
  }

  Future<ApiResponse<UserProfileDto>> _verifyTokenWithBackend(String supabaseToken) async {
    // Set the Supabase token temporarily for verification
    await _apiService.setAuthToken(supabaseToken);
    
    // Call backend to verify token and get/create user profile
    final response = await _apiService.post<UserProfileDto>(
      '/auth/verify',
      {'token': supabaseToken},
      fromJson: (json) => UserProfileDto.fromJson(json),
    );

    if (response.success && response.data != null) {
      // Backend verification successful, keep the token
      return response;
    } else {
      // Backend verification failed, clear token
      await _apiService.clearAuthToken();
      return response;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Supabase
      await _supabase.auth.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Clear backend token
      await _apiService.clearAuthToken();
      
      // Call backend logout endpoint
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      // Still clear local tokens even if backend call fails
      await _apiService.clearAuthToken();
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      try {
        final response = await _supabase.auth.refreshSession();
        if (response.session?.accessToken != null) {
          await _apiService.setAuthToken(response.session!.accessToken);
        } else {
          throw Exception('Failed to refresh token');
        }
      } catch (e) {
        // If refresh fails, sign out
        await signOut();
        rethrow;
      }
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
  
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

}