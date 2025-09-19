// lib/features/MentorMeter/modules/review/services/review_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Create a new review
  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the review has the correct user ID
      final reviewData = review.copyWith(userId: currentUserId!).toCreateJson();

      final response =
          await _supabase.from('review').insert(reviewData).select().single();

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Get all reviews for the current user
  Future<List<ReviewModel>> getReviews({
    int? limit,
    int? offset,
    String? orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase
          .from('review')
          .select()
          .eq('user_id', currentUserId!)
          .order(orderBy!, ascending: ascending);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  /// Get a specific review by ID
  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('review')
          .select()
          .eq('id', reviewId)
          .eq('user_id', currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch review: $e');
    }
  }

  /// Update an existing review
  Future<ReviewModel> updateReview(String reviewId, ReviewModel review) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('review')
          .update(review.toUpdateJson())
          .eq('id', reviewId)
          .eq('user_id', currentUserId!)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('review')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', currentUserId!);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Get reviews by date range
  Future<List<ReviewModel>> getReviewsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String orderBy = 'review_date',
    bool ascending = true,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('review')
          .select()
          .eq('user_id', currentUserId!)
          .gte('review_date', startDate.toIso8601String().split('T')[0])
          .lte('review_date', endDate.toIso8601String().split('T')[0])
          .order(orderBy, ascending: ascending);

      return (response as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch reviews by date range: $e');
    }
  }

  /// Search reviews by topic or names
  Future<List<ReviewModel>> searchReviews(
    String searchTerm, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('review')
          .select()
          .eq('user_id', currentUserId!)
          .or(
            'mentor_name.ilike.%$searchTerm%,'
            'intern_name.ilike.%$searchTerm%,'
            'review_topic.ilike.%$searchTerm%',
          )
          .order(orderBy, ascending: ascending);

      return (response as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search reviews: $e');
    }
  }
}
