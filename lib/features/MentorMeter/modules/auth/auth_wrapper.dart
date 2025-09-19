import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/WEBSOCKET/screens/home_Screen.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/controllers/auth_controller.dart';
import 'package:web_scoket/features/MentorMeter/modules/home/home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Show loading spinner while checking auth state
        if (authController.authState == AuthState.initial) {
          return const Scaffold(
            backgroundColor: Color(0xFFFAFBFC),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
              ),
            ),
          );
        }

        // Navigate based on authentication state
        if (authController.isAuthenticated) {
          // User is logged in, show home screen
          // Replace this with your actual home screen
          return const HomeScreenMentor();
        } else {
          // User is not logged in, show login screen
          return const LoginScreen();
        }
      },
    );
  }
}
