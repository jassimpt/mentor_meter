import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/widgets/custom_fields.dart';
import 'package:web_scoket/features/MentorMeter/modules/reviewForm/controller/review_controller.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({super.key});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Controllers
  final TextEditingController _mentorNameController = TextEditingController();
  final TextEditingController _internNameController = TextEditingController();
  final TextEditingController _reviewDateController = TextEditingController();
  final TextEditingController _reviewTopicController = TextEditingController();
  final TextEditingController _reviewScoreController = TextEditingController();

  DateTime? _selectedDate;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mentorNameController.dispose();
    _internNameController.dispose();
    _reviewDateController.dispose();
    _reviewTopicController.dispose();
    _reviewScoreController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _reviewDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _handleSaveReview() async {
    if (_formKey.currentState!.validate()) {
      final reviewController =
          Provider.of<ReviewController>(context, listen: false);

      final success = await reviewController.createReview(
        mentorName: _mentorNameController.text.trim(),
        internName: _internNameController.text.trim(),
        reviewDate: _selectedDate!,
        reviewTopic: _reviewTopicController.text.trim(),
        reviewScore: int.parse(_reviewScoreController.text.trim()),
      );

      if (!mounted) return;

      if (success) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Review saved successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF059669),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reviewController.errorMessage ?? 'Failed to save review',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                reviewController.clearError();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewController>(
      builder: (context, reviewController, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFBFC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: reviewController.isLoading
                    ? null
                    : () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
            ),
            title: const Text(
              'Create Review',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF4F46E5).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.rate_review_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Document your mentoring session',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Capture insights and track progress effectively',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ],
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

                    // Error Display
                    if (reviewController.hasError)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFDC2626),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFDC2626),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reviewController.errorMessage ??
                                      'An error occurred',
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: reviewController.clearError,
                                child: const Text(
                                  'Dismiss',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Form Fields
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Mentor Name Field
                            CustomFields(
                              controller: _mentorNameController,
                              label: 'Mentor Name',
                              hint: 'Enter mentor\'s full name',
                              prefixIcon: Icons.person_outline_rounded,
                              // enabled: !reviewController.isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Mentor name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Intern Name Field
                            CustomFields(
                              controller: _internNameController,
                              label: 'Intern Name',
                              hint: 'Enter intern\'s full name',
                              prefixIcon: Icons.person_add_alt_outlined,
                              // enabled: !reviewController.isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Intern name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Review Date Field
                            GestureDetector(
                              onTap: reviewController.isLoading
                                  ? null
                                  : _selectDate,
                              child: AbsorbPointer(
                                child: CustomFields(
                                  controller: _reviewDateController,
                                  label: 'Review Date',
                                  hint: 'Select review date',
                                  prefixIcon: Icons.calendar_today_outlined,
                                  // enabled: !reviewController.isLoading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Review date is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Review Topic Field
                            CustomFields(
                              controller: _reviewTopicController,
                              label: 'Review Topic',
                              hint: 'Enter the main topic discussed',
                              prefixIcon: Icons.topic_outlined,
                              // enabled: !reviewController.isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Review topic is required';
                                }
                                if (value.trim().length < 3) {
                                  return 'Topic must be at least 3 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Review Score Field
                            CustomFields(
                              controller: _reviewScoreController,
                              label: 'Review Score',
                              hint: 'Enter score (1-10)',
                              prefixIcon: Icons.star_outline_rounded,
                              keyboardType: TextInputType.number,
                              // enabled: !reviewController.isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Review score is required';
                                }
                                final score = int.tryParse(value.trim());
                                if (score == null) {
                                  return 'Please enter a valid number';
                                }
                                if (score < 1 || score > 10) {
                                  return 'Score must be between 1 and 10';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildSaveButton(reviewController),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(ReviewController reviewController) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: reviewController.isLoading
            ? const LinearGradient(
                colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: reviewController.isLoading
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: reviewController.isLoading ? null : _handleSaveReview,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (reviewController.isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  reviewController.isLoading
                      ? 'Saving Review...'
                      : 'Save Review',
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
    );
  }
}
