import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/modules/scheduleform/controller/schedule_controller.dart';
import 'package:intl/intl.dart';

class ScheduleReportsScreen extends StatefulWidget {
  const ScheduleReportsScreen({super.key});

  @override
  State<ScheduleReportsScreen> createState() => _ScheduleReportsScreenState();
}

class _ScheduleReportsScreenState extends State<ScheduleReportsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _searchTerm = '';
  String _selectedFilter = 'all'; // all, upcoming, past, today

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSearch();
    
    // Fetch initial schedules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleController>().fetchSchedules();
    });
  }

  void _initializeAnimations() {
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

  void _setupSearch() {
    _searchController.addListener(() {
      final searchTerm = _searchController.text.trim();
      if (searchTerm != _searchTerm) {
        setState(() {
          _searchTerm = searchTerm;
        });
        _performSearch();
      }
    });
  }

  void _performSearch() {
    final controller = context.read<ScheduleController>();
    
    if (_selectedStartDate != null && _selectedEndDate != null) {
      // Date range filter with optional search
      controller.fetchSchedulesByDateRange(_selectedStartDate!, _selectedEndDate!);
    } else if (_searchTerm.isNotEmpty) {
      // Search filter
      controller.searchSchedules(_searchTerm);
    } else {
      // Apply status filter
      _applyStatusFilter();
    }
  }

  void _applyStatusFilter() {
    final controller = context.read<ScheduleController>();
    
    switch (_selectedFilter) {
      case 'upcoming':
        controller.fetchUpcomingSchedules();
        break;
      case 'past':
        controller.fetchPastSchedules();
        break;
      case 'today':
        controller.fetchTodaySchedules();
        break;
      default:
        controller.fetchSchedules();
        break;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
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

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _performSearch();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _searchTerm = '';
      _selectedFilter = 'all';
    });
    _searchController.clear();
    context.read<ScheduleController>().fetchSchedules();
  }

  Future<void> _refreshSchedules() async {
    await context.read<ScheduleController>().refresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Top Bar with Back Button and Title
                      Row(
                        children: [
                          // Modern Back Button
                          Container(
                            width: 44,
                            height: 44,
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
                          const SizedBox(width: 16),
                          
                          // Title
                          const Expanded(
                            child: Text(
                              'Schedule Reports',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Search and Filter Row
                      Row(
                        children: [
                          // Search Field
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _searchFocusNode.hasFocus
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Search schedules...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Date Filter Button
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedStartDate != null
                                  ? const Color(0xFF4F46E5).withOpacity(0.1)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedStartDate != null
                                    ? const Color(0xFF4F46E5)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _selectDateRange,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Icon(
                                    Icons.date_range_rounded,
                                    color: _selectedStartDate != null
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusChip('All', 'all'),
                            const SizedBox(width: 8),
                            _buildStatusChip('Upcoming', 'upcoming'),
                            const SizedBox(width: 8),
                            _buildStatusChip('Today', 'today'),
                            const SizedBox(width: 8),
                            _buildStatusChip('Past', 'past'),
                          ],
                        ),
                      ),
                      
                      // Active Filters Display
                      if (_selectedStartDate != null || _searchTerm.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (_selectedStartDate != null)
                                _buildFilterChip(
                                  'Date: ${_formatDateRange()}',
                                  () {
                                    setState(() {
                                      _selectedStartDate = null;
                                      _selectedEndDate = null;
                                    });
                                    _performSearch();
                                  },
                                ),
                              if (_searchTerm.isNotEmpty)
                                _buildFilterChip(
                                  'Search: $_searchTerm',
                                  () {
                                    _searchController.clear();
                                  },
                                ),
                              if (_selectedStartDate != null || _searchTerm.isNotEmpty)
                                TextButton(
                                  onPressed: _clearFilters,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Clear All',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Schedules List
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Consumer<ScheduleController>(
                    builder: (context, scheduleController, child) {
                      return RefreshIndicator(
                        onRefresh: _refreshSchedules,
                        color: const Color(0xFF4F46E5),
                        backgroundColor: Colors.white,
                        child: _buildSchedulesList(scheduleController),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _applyStatusFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4F46E5).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange() {
    if (_selectedStartDate == null || _selectedEndDate == null) return '';
    
    final start = _selectedStartDate!;
    final end = _selectedEndDate!;
    
    if (start.isAtSameMomentAs(end)) {
      return DateFormat('dd/MM/yyyy').format(start);
    }
    
    return '${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM').format(end)}';
  }

  Widget _buildSchedulesList(ScheduleController scheduleController) {
    if (scheduleController.isLoading) {
      return _buildLoadingState();
    }

    if (scheduleController.hasError) {
      return _buildErrorState(scheduleController.errorMessage ?? 'Unknown error occurred');
    }

    if (scheduleController.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: scheduleController.schedules.length,
      itemBuilder: (context, index) {
        final schedule = scheduleController.schedules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildScheduleCard(schedule),
        );
      },
    );
  }

  Widget _buildScheduleCard(schedule) {
    final now = DateTime.now();
    final scheduleDateTime = schedule.scheduleDateTimeComplete;
    final isUpcoming = scheduleDateTime.isAfter(now);
    final isToday = schedule.scheduleDate.year == now.year &&
        schedule.scheduleDate.month == now.month &&
        schedule.scheduleDate.day == now.day;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle schedule tap - navigate to detail screen if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.sessionTopic,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mentor: ${schedule.mentorName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(isUpcoming, isToday),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Intern and DateTime Info
                Row(
                  children: [
                    // Intern Info
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF6B7280),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Intern',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  schedule.internName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Date Time Info
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF6B7280),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(schedule.scheduleDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              schedule.scheduleTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isUpcoming, bool isToday) {
    String text;
    Color backgroundColor;
    Color textColor;

    if (isToday) {
      text = 'Today';
      backgroundColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    } else if (isUpcoming) {
      text = 'Upcoming';
      backgroundColor = const Color(0xFFDCFDF7);
      textColor = const Color(0xFF059669);
    } else {
      text = 'Expired';
      backgroundColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading schedules...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _refreshSchedules,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _selectedStartDate != null || _searchTerm.isNotEmpty || _selectedFilter != 'all';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                hasFilters ? Icons.search_off_rounded : Icons.schedule_outlined,
                color: const Color(0xFF6B7280),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No schedules found' : 'No schedules yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters 
                  ? 'Try adjusting your search or filters'
                  : 'Schedules will appear here once you start creating them',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _clearFilters,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}