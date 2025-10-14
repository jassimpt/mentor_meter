import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/features/MentorMeter/core/utils/pdf_service.dart';
import 'package:web_scoket/features/MentorMeter/modules/reviewForm/controller/review_controller.dart';
import 'package:web_scoket/features/MentorMeter/modules/home/widgets/review_card.dart';

class ReviewReportsScreen extends StatefulWidget {
  const ReviewReportsScreen({super.key});

  @override
  State<ReviewReportsScreen> createState() => _ReviewReportsScreenState();
}

class _ReviewReportsScreenState extends State<ReviewReportsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _searchTerm = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSearch();

    // Fetch initial reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewController>().fetchReviews();
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
    if (_searchTerm.isEmpty &&
        _selectedStartDate == null &&
        _selectedEndDate == null) {
      // No filters, fetch all reviews
      context.read<ReviewController>().fetchReviews();
    } else if (_selectedStartDate != null && _selectedEndDate != null) {
      // Date range filter with optional search
      context.read<ReviewController>().fetchReviewsByDateRange(
            _selectedStartDate!,
            _selectedEndDate!,
          );
    } else if (_searchTerm.isNotEmpty) {
      // Search filter
      context.read<ReviewController>().searchReviews(_searchTerm);
    }
  }

  Future<void> _generatePDF() async {
    final reviewController = context.read<ReviewController>();

    if (reviewController.reviews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No reviews available to generate report'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Generating PDF report...'),
            ],
          ),
          backgroundColor: const Color(0xFF4F46E5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 30),
        ),
      );

      await reviewController.loadPaymentAmount();

      // Generate PDF (adjust paymentPerReview as needed)
      await PdfService.generateAndOpenReport(
        reviews: reviewController.reviews,
        paymentPerReview: reviewController.singleReviewPayment,
      );

      // Hide loading and show success
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('PDF generated successfully'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      // Hide loading and show error
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
    });
    _searchController.clear();
    context.read<ReviewController>().fetchReviews();
  }

  Future<void> _refreshReviews() async {
    await context.read<ReviewController>().refresh();
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
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  'Review Reports',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const Spacer(),
                                // PDF Generate Button
                                Container(
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
                                      onTap: _generatePDF,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.picture_as_pdf_rounded,
                                              color: Color(0xFF4F46E5),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'PDF',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                  hintText: 'Search reviews...',
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                              if (_selectedStartDate != null ||
                                  _searchTerm.isNotEmpty)
                                TextButton(
                                  onPressed: _clearFilters,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
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

            // Reviews List
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Consumer<ReviewController>(
                    builder: (context, reviewController, child) {
                      return RefreshIndicator(
                        onRefresh: _refreshReviews,
                        color: const Color(0xFF4F46E5),
                        backgroundColor: Colors.white,
                        child: _buildReviewsList(reviewController),
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
      return '${start.day}/${start.month}/${start.year}';
    }

    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  Widget _buildReviewsList(ReviewController reviewController) {
    if (reviewController.isLoading) {
      return _buildLoadingState();
    }

    if (reviewController.hasError) {
      return _buildErrorState(
          reviewController.errorMessage ?? 'Unknown error occurred');
    }

    if (reviewController.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: reviewController.reviews.length,
      itemBuilder: (context, index) {
        final review = reviewController.reviews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ReviewCard(
            review: review,
            onTap: () {
              // Handle review tap - navigate to detail screen if needed
            },
          ),
        );
      },
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
            'Loading reviews...',
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
                  onTap: _refreshReviews,
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
    final hasFilters = _selectedStartDate != null || _searchTerm.isNotEmpty;

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
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.rate_review_outlined,
                color: const Color(0xFF6B7280),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No reviews found' : 'No reviews yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or date filters'
                  : 'Reviews will appear here once you start creating them',
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
