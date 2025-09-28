import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scoket/features/MentorMeter/modules/home/home_screen.dart';

class PaymentConfigScreen extends StatefulWidget {
  final bool isFromLogin;
  const PaymentConfigScreen({
    super.key,
    required this.isFromLogin,
  });

  @override
  State<PaymentConfigScreen> createState() => _PaymentConfigScreenState();
}

class _PaymentConfigScreenState extends State<PaymentConfigScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _displayAmount = '250';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
    _loadCurrentPayment();
  }

  Future<void> _loadCurrentPayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPayment = prefs.getDouble('per_review_payment') ?? 250.0;
      setState(() {
        _displayAmount = savedPayment.toStringAsFixed(0);
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_displayAmount == '0' || _displayAmount == '250') {
        _displayAmount = number;
      } else if (_displayAmount.length < 6) {
        // Limit to 6 digits
        _displayAmount += number;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onClearPressed() {
    setState(() {
      _displayAmount = '0';
    });
    HapticFeedback.lightImpact();
  }

  void _onBackspacePressed() {
    setState(() {
      if (_displayAmount.length > 1) {
        _displayAmount = _displayAmount.substring(0, _displayAmount.length - 1);
      } else {
        _displayAmount = '0';
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _savePaymentAmount() async {
    if (_displayAmount.isEmpty || _displayAmount == '0') {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final amount = double.parse(_displayAmount);
      await prefs.setDouble('per_review_payment', amount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment amount saved successfully!'),
            backgroundColor: Color(0xFF059669),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after a short delay

        if (mounted) {
          if (widget.isFromLogin) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenMentor(),
              ),
              (route) => false,
            );
          } else {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save payment amount');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF4F46E5),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Amount Display
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Amount per Review',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4F46E5),
                                height: 1.2,
                              ),
                            ),
                            Text(
                              _displayAmount,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                letterSpacing: -1.0,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Calculator Grid
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        // Number buttons
                        _buildCalculatorButton('1'),
                        _buildCalculatorButton('2'),
                        _buildCalculatorButton('3'),
                        _buildCalculatorButton('4'),
                        _buildCalculatorButton('5'),
                        _buildCalculatorButton('6'),
                        _buildCalculatorButton('7'),
                        _buildCalculatorButton('8'),
                        _buildCalculatorButton('9'),
                        _buildCalculatorButton(
                          'C',
                          isAction: true,
                          onTap: _onClearPressed,
                        ),
                        _buildCalculatorButton('0'),
                        _buildCalculatorButton(
                          '⌫',
                          isAction: true,
                          onTap: _onBackspacePressed,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isLoading ? null : _savePaymentAmount,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading) ...[
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _isLoading
                                      ? 'Saving...'
                                      : 'Save Payment Rate',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(
    String text, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAction ? const Color(0xFF4F46E5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAction ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAction
                ? const Color(0xFF4F46E5).withOpacity(0.15)
                : const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => _onNumberPressed(text),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: text == '⌫' ? 18 : 24,
                fontWeight: FontWeight.w600,
                color: isAction ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
