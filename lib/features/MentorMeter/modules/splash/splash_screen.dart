import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/auth_wrapper.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/controllers/auth_controller.dart';
import 'package:web_scoket/features/MentorMeter/modules/splash/widgets/feature_icon_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();

    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Initialize auth controller
    final authController = context.read<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.initializeAuth();
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to AuthWrapper which will handle the routing
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Icon Container
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 30,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFE8EBF0),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.bar_chart_rounded,
                                  size: 48,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // App Name
                              SlideTransition(
                                position: _slideAnimation,
                                child: const Column(
                                  children: [
                                    Text(
                                      'MentorMeter',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Track • Schedule • Manage Reviews',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FeatureIconWidget(
                                    icon: Icons.schedule_outlined,
                                    label: 'Schedule'),
                                FeatureIconWidget(
                                    icon: Icons.analytics_outlined,
                                    label: 'Analytics'),
                                FeatureIconWidget(
                                    icon: Icons.payment_outlined,
                                    label: 'Payments'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: 32,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: const Color(0xFFE5E7EB),
                            ),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _animationController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Professional Review Management',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
