import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'api_service.dart';
import '../models/api_response.dart';
import '../models/dto/user_profile_dto.dart';

class AuthService {
  final ApiService _apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._apiService);

  Future<ApiResponse<UserProfileDto>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      // Sign in with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Sign in failed'),
        );
      }

      // Get Firebase ID token
      final idToken = await credential.user!.getIdToken();
      if (idToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend and get user profile
      return await _verifyTokenWithBackend(idToken);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(
        ApiError.authentication(_getFirebaseErrorMessage(e.code)),
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
      // Create user with Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Sign up failed'),
        );
      }

      // Get Firebase ID token
      final idToken = await credential.user!.getIdToken();
      if (idToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend and create user profile
      return await _verifyTokenWithBackend(idToken);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(
        ApiError.authentication(_getFirebaseErrorMessage(e.code)),
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

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Google sign in failed'),
        );
      }

      // Get Firebase ID token
      final idToken = await userCredential.user!.getIdToken();
      if (idToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend
      return await _verifyTokenWithBackend(idToken);
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

      // Create an Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        return ApiResponse.error(
          ApiError.authentication('Apple sign in failed'),
        );
      }

      // Get Firebase ID token
      final idToken = await userCredential.user!.getIdToken();
      if (idToken == null) {
        return ApiResponse.error(
          ApiError.authentication('Failed to get authentication token'),
        );
      }
      
      // Verify with backend
      return await _verifyTokenWithBackend(idToken);
    } catch (e) {
      return ApiResponse.error(
        ApiError.authentication('Apple sign in error: ${e.toString()}'),
      );
    }
  }

  Future<ApiResponse<UserProfileDto>> _verifyTokenWithBackend(String firebaseToken) async {
    // Set the Firebase token temporarily for verification
    await _apiService.setAuthToken(firebaseToken);
    
    // Call backend to verify token and get/create user profile
    final response = await _apiService.post<UserProfileDto>(
      '/auth/verify',
      {'token': firebaseToken},
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
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
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
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final idToken = await currentUser.getIdToken(true); // Force refresh
        if (idToken != null) {
          await _apiService.setAuthToken(idToken);
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

  User? get currentUser => _firebaseAuth.currentUser;
  
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return 'Authentication error: $code';
    }
  }
}