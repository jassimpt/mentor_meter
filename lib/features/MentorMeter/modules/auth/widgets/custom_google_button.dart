import 'package:flutter/material.dart';

class CustomGoogleButton extends StatelessWidget {
  const CustomGoogleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        onPressed: () {},
        icon: Container(
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
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
            letterSpacing: 0.1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
