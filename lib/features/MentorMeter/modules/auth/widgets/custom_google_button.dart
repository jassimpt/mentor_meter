import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/controllers/auth_controller.dart';
import 'package:web_scoket/features/MentorMeter/modules/home/home_screen.dart';
import 'package:web_scoket/features/MentorMeter/modules/paymentConfig/payment_config_screen.dart';

class CustomGoogleButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const CustomGoogleButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: authController.isGoogleSigninLoading
                ? null
                : () => _handleGoogleSignIn(context, authController),
            icon: authController.isGoogleSigninLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF374151)),
                    ),
                  )
                : Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://developers.google.com/identity/images/g-logo.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            label: Text(
              authController.isGoogleSigninLoading
                  ? 'Signing in...'
                  : 'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: authController.isGoogleSigninLoading
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF374151),
                letterSpacing: 0.1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(
                color: authController.isGoogleSigninLoading
                    ? const Color(0xFFE5E7EB).withOpacity(0.5)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthController authController,
  ) async {
    final success = await authController.signInWithGoogle();

    // Check if the widget is still mounted before proceeding
    if (!context.mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${authController.userDisplayName ?? 'User'}!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Call success callback if provided
      onSuccess?.call();

      // Navigate to home screen - use a small delay to ensure the widget is properly mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentConfigScreen(
                isFromLogin: true,
              ),
            ),
            (route) => false,
          );
        }
      });
    } else {
      // Show error message if there's one from the controller
      if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Call error callback
      onError?.call();
    }
  }
}
