import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'display_name': fullName,
        },
      );

      // If signup is successful and user is confirmed, update the profile
      if (response.user != null) {
        await _updateUserProfile(
          userId: response.user!.id,
          fullName: fullName,
          email: email,
        );
      }

      return response;
    } on AuthException catch (e) {
      debugPrint('Auth Exception: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      throw AuthException('An unexpected error occurred during signup');
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth Exception: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during signin: $e');
      throw AuthException('An unexpected error occurred during signin');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('Sign out exception: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during signout: $e');
      throw AuthException('An unexpected error occurred during signout');
    }
  }

  // Private method to update user profile in profiles table
  static Future<void> _updateUserProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (email != null) updates['email'] = email;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').upsert({
        'id': userId,
        ...updates,
      });
    } catch (e) {
      debugPrint('Error updating profile in database: $e');
      // Don't rethrow here as the main auth operation might have succeeded
    }
  }
}
