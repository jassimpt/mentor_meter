import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:web_scoket/core/constants/supabase_constants.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Configure Google Sign-In
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? SupabaseConstants.iosAuthClientId : null,
    serverClientId: SupabaseConstants.serverAuthclientId,
  );

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

  // Sign in with Google
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google to get access token and ID token
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign-in was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw AuthException('Failed to get Google authentication tokens');
      }

      // Step 2: Use tokens to sign in with Supabase
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Step 3: Update user profile if sign-in is successful
      if (response.user != null) {
        await _updateUserProfile(
          userId: response.user!.id,
          fullName: googleUser.displayName ?? '',
          email: googleUser.email,
          avatarUrl: googleUser.photoUrl,
        );
      }

      return response;
    } on AuthException catch (e) {
      debugPrint('Google Auth Exception: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during Google signin: $e');
      throw AuthException('An unexpected error occurred during Google signin');
    }
  }

  // Sign out (handles both regular and Google sign out)
  static Future<void> signOut() async {
    try {
      // Sign out from Google if currently signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Supabase
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('Sign out exception: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during signout: $e');
      throw AuthException('An unexpected error occurred during signout');
    }
  }

  // Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
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

      if (fullName != null && fullName.isNotEmpty)
        updates['full_name'] = fullName;
      if (email != null && email.isNotEmpty) updates['email'] = email;
      if (avatarUrl != null && avatarUrl.isNotEmpty)
        updates['avatar_url'] = avatarUrl;

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
