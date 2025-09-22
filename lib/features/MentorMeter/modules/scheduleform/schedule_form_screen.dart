import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/modules/auth/widgets/custom_fields.dart';
import 'package:web_scoket/features/MentorMeter/modules/scheduleform/controller/schedule_controller.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({super.key});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _mentorNameController = TextEditingController();
  final TextEditingController _internNameController = TextEditingController();
  final TextEditingController _reviewDateController = TextEditingController();
  final TextEditingController _reviewTopicController = TextEditingController();
  final TextEditingController _reviewTimeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ScheduleController _scheduleController;

  @override
  void initState() {
    super.initState();
    _scheduleController =
        Provider.of<ScheduleController>(context, listen: false);

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

    // Listen to controller state changes
    _scheduleController.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    if (_scheduleController.isSuccess) {
      _showSuccessMessage();
      _clearForm();
    } else if (_scheduleController.hasError) {
      _showErrorMessage(
          _scheduleController.errorMessage ?? 'An error occurred');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Session scheduled successfully!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _clearForm() {
    _mentorNameController.clear();
    _internNameController.clear();
    _reviewDateController.clear();
    _reviewTopicController.clear();
    _reviewTimeController.clear();
    _selectedDate = null;
    _selectedTime = null;
    _scheduleController.clearError();
  }

  @override
  void dispose() {
    _scheduleController.removeListener(_handleStateChange);
    _animationController.dispose();
    _mentorNameController.dispose();
    _internNameController.dispose();
    _reviewDateController.dispose();
    _reviewTopicController.dispose();
    _reviewTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _reviewTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _handleSaveSchedule() async {
    if (_formKey.currentState!.validate()) {
      // Clear any previous errors
      _scheduleController.clearError();

      // Validate that date and time are selected
      if (_selectedDate == null || _selectedTime == null) {
        _showErrorMessage('Please select both date and time for the session');
        return;
      }

      // Create the schedule using the controller
      final success = await _scheduleController.createSchedule(
        mentorName: _mentorNameController.text.trim(),
        internName: _internNameController.text.trim(),
        scheduleDate: _selectedDate!,
        scheduleTime: _reviewTimeController.text,
        sessionTopic: _reviewTopicController.text.trim(),
      );

      // Navigation on success is handled in the state change listener
      if (success) {
        // Optionally navigate back or to another screen after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleController>(
      builder: (context, scheduleController, child) {
        final isLoading = scheduleController.isLoading;

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
                onPressed: isLoading ? null : () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF059669),
                  size: 18,
                ),
              ),
            ),
            title: const Text(
              'Schedule Session',
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
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF059669).withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
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
                                      Icons.schedule_outlined,
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
                                          'Schedule your mentoring session',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Plan and organize your upcoming sessions efficiently',
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

                    // Error Message Display
                    if (scheduleController.hasError &&
                        scheduleController.errorMessage != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  scheduleController.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    scheduleController.clearError(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFFEF4444),
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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

                            // Schedule Date Field
                            GestureDetector(
                              onTap: isLoading ? null : _selectDate,
                              child: AbsorbPointer(
                                child: CustomFields(
                                  controller: _reviewDateController,
                                  label: 'Schedule Date',
                                  hint: 'Select schedule date',
                                  prefixIcon: Icons.calendar_today_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Schedule date is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Schedule Topic Field
                            CustomFields(
                              controller: _reviewTopicController,
                              label: 'Session Topic',
                              hint: 'Enter the main topic to discuss',
                              prefixIcon: Icons.topic_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Session topic is required';
                                }
                                if (value.trim().length < 3) {
                                  return 'Topic must be at least 3 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Schedule Time Field
                            GestureDetector(
                              onTap: isLoading ? null : _selectTime,
                              child: AbsorbPointer(
                                child: CustomFields(
                                  controller: _reviewTimeController,
                                  label: 'Schedule Time',
                                  hint: 'Select session time',
                                  prefixIcon: Icons.access_time_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Schedule time is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
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
                        child: _buildSaveButton(isLoading),
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

  Widget _buildSaveButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isLoading
            ? const LinearGradient(
                colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLoading
            ? []
            : [
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
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : _handleSaveSchedule,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
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
                    Icons.schedule_send_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  isLoading ? 'Scheduling...' : 'Schedule Session',
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
