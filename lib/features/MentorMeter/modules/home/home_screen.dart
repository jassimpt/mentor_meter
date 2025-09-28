import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_scoket/core/constants/app_constants.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/controllers/auth_controller.dart';
import 'package:web_scoket/features/MentorMeter/modules/home/widgets/review_card.dart';
import 'package:web_scoket/features/MentorMeter/modules/paymentConfig/payment_config_screen.dart';
import 'package:web_scoket/features/MentorMeter/modules/reports/review_reports_screen.dart';
import 'package:web_scoket/features/MentorMeter/modules/reports/schedule_reports_screen.dart';
import 'package:web_scoket/features/MentorMeter/modules/reviewForm/controller/review_controller.dart';
import 'package:web_scoket/features/MentorMeter/modules/reviewForm/review_form_screen.dart';
import 'package:web_scoket/features/MentorMeter/modules/scheduleform/schedule_form_screen.dart';

class HomeScreenMentor extends StatefulWidget {
  const HomeScreenMentor({super.key});

  @override
  State<HomeScreenMentor> createState() => _HomeScreenMentorState();
}

class _HomeScreenMentorState extends State<HomeScreenMentor>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _appVersion = '';

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
    _loadAppVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewController>().fetchReviews();
      context.read<ReviewController>().loadPaymentAmount();
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'v1.0.0'; // Fallback version
      });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Welcome Message
                        Consumer<AuthController>(
                          builder: (context, authController, child) {
                            return Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authController.userDisplayName ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                      letterSpacing: -0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Menu Icon
                        Container(
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
                              onTap: () {
                                // Handle menu tap
                                _showMenuOptions(context);
                              },
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Color(0xFF4F46E5),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Dashboard Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Dashboard Cards
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Consumer<ReviewController>(
                      builder: (context, reviewController, child) {
                        return GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildDashboardCard(
                              title: 'Total Reviews',
                              subtitle: 'This Month',
                              value: reviewController.totalReviewsThisMonth
                                  .toString(),
                              icon: Icons.rate_review_outlined,
                              color: const Color(0xFF4F46E5),
                            ),
                            _buildDashboardCard(
                              title: 'Total Payment',
                              subtitle: 'This Month',
                              value: reviewController
                                  .totalPaymentThisMonthFormatted,
                              icon: Icons.payments_outlined,
                              color: const Color(0xFF059669),
                            ),
                            _buildDashboardCard(
                              title: 'Reviews Today',
                              subtitle: 'Today',
                              value:
                                  reviewController.totalReviewsToday.toString(),
                              icon: Icons.today_outlined,
                              color: const Color(0xFFDC2626),
                            ),
                            _buildDashboardCard(
                              title: 'Today\'s Earnings',
                              subtitle: 'Today',
                              value:
                                  reviewController.totalEarningsTodayFormatted,
                              icon: Icons.trending_up_rounded,
                              color: const Color(0xFFD97706),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      children: [
                        Expanded(child: _buildSaveReviewButton()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildScheduleReviewButton()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Latest Reviews',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.2,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewReportsScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Reviews List
                        Consumer<ReviewController>(
                          builder: (context, reviewController, child) {
                            if (reviewController.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4F46E5),
                                ),
                              );
                            }

                            if (reviewController.hasError) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFEF4444)),
                                ),
                                child: Text(
                                  'Error loading reviews: ${reviewController.errorMessage}',
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }

                            if (reviewController.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.rate_review_outlined,
                                        size: 32,
                                        color: Color(0xFF6B7280),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No reviews yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: reviewController.reviews
                                  .take(4)
                                  .map((review) => ReviewCard(
                                        review: review,
                                        onTap: () {
                                          // Handle review tap - navigate to detail screen
                                        },
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          // Title and Subtitle
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Add this to allow custom sizing
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.75, // Limit height to 75% of screen
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuOption(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to profile
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.assessment_outlined,
                      title: 'Review Reports',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewReportsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.schedule_outlined,
                      title: 'Schedule Reports',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleReportsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.payments_outlined,
                      title: 'Payment Settings',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentConfigScreen(
                              isFromLogin: false,
                            ),
                          ),
                        );

                        // If payment was updated, refresh the review controller
                        if (result == true && mounted) {
                          final reviewController =
                              context.read<ReviewController>();
                          await reviewController
                              .loadPaymentAmount(); // This will trigger UI update
                        }
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.help_outline,
                      title: 'Developer Info',
                      onTap: () async {
                        Navigator.pop(context);
                        await _launchLinkedInProfile();
                      },
                    ),
                    const Divider(height: 32),
                    _buildMenuOption(
                      icon: Icons.logout_outlined,
                      title: 'Sign Out',
                      onTap: () async {
                        Navigator.pop(context);
                        final authController = context.read<AuthController>();
                        await authController.signOut();
                      },
                      isDestructive: true,
                    ),
                    const SizedBox(height: 16),

                    // App Version Display
                    Text(
                      _appVersion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 116, 116, 116),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchLinkedInProfile() async {
    final Uri linkedInUrl = Uri.parse(AppConstants.linkedinurl);

    try {
      if (await canLaunchUrl(linkedInUrl)) {
        await launchUrl(
          linkedInUrl,
          mode: LaunchMode.platformDefault,
        );
      } else {
        // Show error message if URL can't be launched
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open LinkedIn profile'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening LinkedIn profile'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color:
              isDestructive ? const Color(0xFFDC2626) : const Color(0xFF1F2937),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildScheduleReviewButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _handleScheduleReview();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Schedule',
                  style: TextStyle(
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
    );
  }

  Widget _buildSaveReviewButton() {
    return Container(
      width: double.infinity,
      height: 56,
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
          onTap: () {
            // Handle save review action
            _handleSaveReview();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Save Review',
                  style: TextStyle(
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
    );
  }

  void _handleSaveReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReviewFormScreen(),
      ),
    );
  }

  void _handleScheduleReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleFormScreen(),
      ),
    );
  }
}
