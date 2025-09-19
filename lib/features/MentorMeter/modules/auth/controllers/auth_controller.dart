import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/service/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController extends ChangeNotifier {
  // State management
  AuthState _authState = AuthState.initial;
  String? _errorMessage;
  User? _currentUser;

  // UI state management
  bool _isPasswordVisible = false;
  bool _isSignupLoading = false;
  bool _isSigninLoading = false;

  // Getters
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isSignupLoading => _isSignupLoading;
  bool get isSigninLoading => _isSigninLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _isSignupLoading || _isSigninLoading;

  // Initialize auth state
  void initializeAuth() {
    _currentUser = SupabaseAuthService.currentUser;
    _authState = SupabaseAuthService.isAuthenticated
        ? AuthState.authenticated
        : AuthState.unauthenticated;
    notifyListeners();

    // Listen to auth changes
    _listenToAuthChanges();
  }

  // Listen to auth state changes
  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _currentUser = session?.user;
          _authState = AuthState.authenticated;
          _clearError();
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          _authState = AuthState.unauthenticated;
          _clearError();
          break;
        case AuthChangeEvent.userUpdated:
          _currentUser = session?.user;
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  // Toggle password visibility
  void setPasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Sign up method
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _setSignupLoading(true);
      _clearError();

      final response = await SupabaseAuthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        _currentUser = response.user;

        // Check if email confirmation is required
        if (response.session != null) {
          _authState = AuthState.authenticated;
        } else {
          // Email confirmation required
          _authState = AuthState.unauthenticated;
          _setError('Please check your email and confirm your account');
        }

        return true;
      } else {
        _setError('Sign up failed. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Signup error: $e');
      return false;
    } finally {
      _setSignupLoading(false);
    }
  }

  // Sign in method
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setSigninLoading(true);
      _clearError();

      final response = await SupabaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _authState = AuthState.authenticated;
        return true;
      } else {
        _setError('Sign in failed. Please check your credentials.');
        return false;
      }
    } on AuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Signin error: $e');
      return false;
    } finally {
      _setSigninLoading(false);
    }
  }

  // Sign out method
  Future<bool> signOut() async {
    try {
      _setSigninLoading(true);
      await SupabaseAuthService.signOut();
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      _clearError();
      return true;
    } on AuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
      debugPrint('Signout error: $e');
      return false;
    } finally {
      _setSigninLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _setSigninLoading(true);
      _clearError();

      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('Failed to send reset email. Please try again.');
      debugPrint('Password reset error: $e');
      return false;
    } finally {
      _setSigninLoading(false);
    }
  }

  // Handle AuthExceptions
  void _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          _setError('Invalid email or password');
        } else if (e.message.contains('User already registered')) {
          _setError('An account with this email already exists');
        } else {
          _setError(e.message);
        }
        break;
      case '422':
        _setError('Please check your input and try again');
        break;
      case '429':
        _setError('Too many requests. Please wait and try again');
        break;
      default:
        _setError(e.message);
    }
    _authState = AuthState.error;
  }

  // Private helper methods
  void _setSignupLoading(bool loading) {
    _isSignupLoading = loading;
    notifyListeners();
  }

  void _setSigninLoading(bool loading) {
    _isSigninLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _authState = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_authState == AuthState.error) {
      _authState = SupabaseAuthService.isAuthenticated
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Clear error message manually
  void clearError() {
    _clearError();
  }

  // Get user display name
  String? get userDisplayName {
    if (_currentUser?.userMetadata?['full_name'] != null) {
      return _currentUser!.userMetadata!['full_name'];
    }
    return _currentUser?.email?.split('@')[0];
  }

  // Get user avatar URL
  String? get userAvatarUrl {
    return _currentUser?.userMetadata?['avatar_url'];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
