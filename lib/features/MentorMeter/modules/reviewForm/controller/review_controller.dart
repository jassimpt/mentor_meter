import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scoket/features/MentorMeter/modules/reviewForm/service/review_service.dart';
import '../models/review_model.dart';

enum ReviewState {
  idle,
  loading,
  success,
  error,
}

class ReviewController extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  // Payment per review - will be loaded from SharedPreferences
  double _singleReviewPayment = 0;
  double get singleReviewPayment => _singleReviewPayment;

  // State management
  ReviewState _state = ReviewState.idle;
  ReviewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ReviewState.loading;
  bool get hasError => _state == ReviewState.error;
  bool get isSuccess => _state == ReviewState.success;

  // Data storage
  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => [..._reviews];

  ReviewModel? _currentReview;
  ReviewModel? get currentReview => _currentReview;

  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? get statistics => _statistics;

  // Constructor - Initialize payment amount
  ReviewController() {
    loadPaymentAmount();
  }

  // Load payment amount from SharedPreferences
  Future<void> loadPaymentAmount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPayment = prefs.getDouble('per_review_payment');
      if (savedPayment != null) {
        _singleReviewPayment = savedPayment;
        notifyListeners(); // Notify listeners to update UI with new payment amount
      }
    } catch (e) {
      // If error loading, keep default value
      if (kDebugMode) {
        print('Error loading payment amount: $e');
      }
    }
  }

  // Method to update payment amount (called when user changes it)
  Future<void> updatePaymentAmount(double newAmount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('per_review_payment', newAmount);
      _singleReviewPayment = newAmount;
      notifyListeners(); // Update UI with new calculations
    } catch (e) {
      if (kDebugMode) {
        print('Error saving payment amount: $e');
      }
    }
  }

  // Private method to set state and notify listeners
  void _setState(ReviewState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Create a new review
  Future<bool> createReview({
    required String mentorName,
    required String internName,
    required DateTime reviewDate,
    required String reviewTopic,
    required int reviewScore,
  }) async {
    try {
      _setState(ReviewState.loading);

      final review = ReviewModel(
        userId: '',
        mentorName: mentorName,
        internName: internName,
        reviewDate: reviewDate,
        reviewTopic: reviewTopic,
        reviewScore: reviewScore,
      );

      final createdReview = await _reviewService.createReview(review);

      // Add to local list
      _reviews.insert(0, createdReview);

      _setState(ReviewState.success);
      return true;
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
      return false;
    }
  }

  /// Fetch all reviews
  Future<void> fetchReviews({
    int? limit,
    int? offset,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      _setState(ReviewState.loading);

      final fetchedReviews = await _reviewService.getReviews(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        ascending: ascending,
      );

      _reviews = fetchedReviews;
      _setState(ReviewState.success);
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
    }
  }

  /// Fetch a specific review by ID
  Future<void> fetchReviewById(String reviewId) async {
    try {
      _setState(ReviewState.loading);

      final review = await _reviewService.getReviewById(reviewId);
      _currentReview = review;

      _setState(ReviewState.success);
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
    }
  }

  /// Update an existing review
  Future<bool> updateReview({
    required String reviewId,
    required String mentorName,
    required String internName,
    required DateTime reviewDate,
    required String reviewTopic,
    required int reviewScore,
  }) async {
    try {
      _setState(ReviewState.loading);

      final updatedReview = ReviewModel(
        userId: '',
        mentorName: mentorName,
        internName: internName,
        reviewDate: reviewDate,
        reviewTopic: reviewTopic,
        reviewScore: reviewScore,
      );

      final result = await _reviewService.updateReview(reviewId, updatedReview);

      // Update in local list
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        _reviews[index] = result;
      }

      _setState(ReviewState.success);
      return true;
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
      return false;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      _setState(ReviewState.loading);

      await _reviewService.deleteReview(reviewId);

      // Remove from local list
      _reviews.removeWhere((review) => review.id == reviewId);

      _setState(ReviewState.success);
      return true;
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
      return false;
    }
  }

  /// Search reviews
  Future<void> searchReviews(
    String searchTerm, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      _setState(ReviewState.loading);

      final searchResults = await _reviewService.searchReviews(
        searchTerm,
        orderBy: orderBy,
        ascending: ascending,
      );

      _reviews = searchResults;
      _setState(ReviewState.success);
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
    }
  }

  /// Fetch reviews by date range
  Future<void> fetchReviewsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String orderBy = 'review_date',
    bool ascending = true,
  }) async {
    try {
      _setState(ReviewState.loading);

      final dateRangeReviews = await _reviewService.getReviewsByDateRange(
        startDate,
        endDate,
        orderBy: orderBy,
        ascending: ascending,
      );

      _reviews = dateRangeReviews;
      _setState(ReviewState.success);
    } catch (e) {
      _setState(ReviewState.error, error: e.toString());
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == ReviewState.error) {
      _setState(ReviewState.idle);
    }
  }

  /// Reset controller state
  void reset() {
    _reviews.clear();
    _currentReview = null;
    _statistics = null;
    _setState(ReviewState.idle);
  }

  /// Refresh data (fetch reviews again)
  Future<void> refresh() async {
    await fetchReviews();
  }

  // Utility methods

  /// Get reviews count
  int get reviewsCount => _reviews.length;

  /// Check if reviews list is empty
  bool get isEmpty => _reviews.isEmpty;

  /// Get average score from loaded reviews
  double get averageScore {
    if (_reviews.isEmpty) return 0.0;
    final total =
        _reviews.fold<int>(0, (sum, review) => sum + review.reviewScore);
    return total / _reviews.length;
  }

  /// Get highest score from loaded reviews
  int get highestScore {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.reviewScore).reduce((a, b) => a > b ? a : b);
  }

  /// Get lowest score from loaded reviews
  int get lowestScore {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.reviewScore).reduce((a, b) => a < b ? a : b);
  }

  /// Get reviews for a specific month
  List<ReviewModel> getReviewsForMonth(DateTime month) {
    return _reviews.where((review) {
      return review.reviewDate.year == month.year &&
          review.reviewDate.month == month.month;
    }).toList();
  }

  // STATISTICS METHODS - Updated to use dynamic payment amount

  /// Get total reviews this month
  int get totalReviewsThisMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    return _reviews.where((review) {
      return review.reviewDate.year == thisMonth.year &&
          review.reviewDate.month == thisMonth.month;
    }).length;
  }

  /// Get total payment this month (reviews * dynamic payment per review)
  double get totalPaymentThisMonth {
    return totalReviewsThisMonth * _singleReviewPayment;
  }

  /// Get total reviews today
  int get totalReviewsToday {
    final today = DateTime.now();
    return _reviews.where((review) {
      return review.reviewDate.year == today.year &&
          review.reviewDate.month == today.month &&
          review.reviewDate.day == today.day;
    }).length;
  }

  /// Get total earnings today (today's reviews * dynamic payment per review)
  double get totalEarningsToday {
    return totalReviewsToday * _singleReviewPayment;
  }

  /// Get formatted total payment this month as string
  String get totalPaymentThisMonthFormatted {
    final amount = totalPaymentThisMonth;
    return '₹${amount.toStringAsFixed(0)}';
  }

  /// Get formatted total earnings today as string
  String get totalEarningsTodayFormatted {
    final amount = totalEarningsToday;
    return '₹${amount.toStringAsFixed(0)}';
  }

  /// Get reviews for yesterday to compare with today
  int get totalReviewsYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _reviews.where((review) {
      return review.reviewDate.year == yesterday.year &&
          review.reviewDate.month == yesterday.month &&
          review.reviewDate.day == yesterday.day;
    }).length;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
