import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/controllers/auth_controller.dart';

class CustomFields extends StatelessWidget {
  CustomFields({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  bool isPassword;
  TextInputType? keyboardType;
  final String? Function(String?)? validator;

  //   required TextEditingController controller,
  // required String label,
  // required String hint,
  // required IconData prefixIcon,
  // bool isPassword = false,
  // TextInputType? keyboardType,

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Consumer<AuthController>(
            builder: (context, value, child) => TextFormField(
              controller: controller,
              obscureText: isPassword && !value.isPasswordVisible,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF).withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  prefixIcon,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        onPressed: () {
                          value.setPasswordVisibility();
                        },
                        icon: Icon(
                          value.isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF6B7280),
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4F46E5),
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: validator ??
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
            ),
          ),
        ),
      ],
    );
  }
}
