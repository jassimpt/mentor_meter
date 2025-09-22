// lib/features/MentorMeter/modules/schedule/services/schedule_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_scoket/features/MentorMeter/modules/scheduleform/model/schedule_model.dart';

class ScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Create a new schedule
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the schedule has the correct user ID
      final scheduleData = schedule.copyWith(userId: currentUserId!).toCreateJson();

      final response =
          await _supabase.from('schedule').insert(scheduleData).select().single();

      return ScheduleModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  /// Get all schedules for the current user
  Future<List<ScheduleModel>> getSchedules({
    int? limit,
    int? offset,
    String? orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase
          .from('schedule')
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
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  /// Get a specific schedule by ID
  Future<ScheduleModel?> getScheduleById(String scheduleId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('schedule')
          .select()
          .eq('id', scheduleId)
          .eq('user_id', currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      return ScheduleModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  /// Update an existing schedule
  Future<ScheduleModel> updateSchedule(String scheduleId, ScheduleModel schedule) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('schedule')
          .update(schedule.toUpdateJson())
          .eq('id', scheduleId)
          .eq('user_id', currentUserId!)
          .select()
          .single();

      return ScheduleModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('schedule')
          .delete()
          .eq('id', scheduleId)
          .eq('user_id', currentUserId!);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  /// Get schedules by date range
  Future<List<ScheduleModel>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('schedule')
          .select()
          .eq('user_id', currentUserId!)
          .gte('schedule_date', startDate.toIso8601String().split('T')[0])
          .lte('schedule_date', endDate.toIso8601String().split('T')[0])
          .order(orderBy, ascending: ascending);

      return (response as List)
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch schedules by date range: $e');
    }
  }

  /// Search schedules by topic or names
  Future<List<ScheduleModel>> searchSchedules(
    String searchTerm, {
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('schedule')
          .select()
          .eq('user_id', currentUserId!)
          .or(
            'mentor_name.ilike.%$searchTerm%,'
            'intern_name.ilike.%$searchTerm%,'
            'session_topic.ilike.%$searchTerm%',
          )
          .order(orderBy, ascending: ascending);

      return (response as List)
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search schedules: $e');
    }
  }

  /// Get upcoming schedules (future schedules)
  Future<List<ScheduleModel>> getUpcomingSchedules({
    int? limit,
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      var query = _supabase
          .from('schedule')
          .select()
          .eq('user_id', currentUserId!)
          .gte('schedule_date', today)
          .order(orderBy, ascending: ascending);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch upcoming schedules: $e');
    }
  }

  /// Get past schedules
  Future<List<ScheduleModel>> getPastSchedules({
    int? limit,
    String orderBy = 'schedule_date',
    bool ascending = false,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      var query = _supabase
          .from('schedule')
          .select()
          .eq('user_id', currentUserId!)
          .lt('schedule_date', today)
          .order(orderBy, ascending: ascending);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch past schedules: $e');
    }
  }

  /// Get schedules for today
  Future<List<ScheduleModel>> getTodaySchedules() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('schedule')
          .select()
          .eq('user_id', currentUserId!)
          .eq('schedule_date', today)
          .order('schedule_time', ascending: true);

      return (response as List)
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch today\'s schedules: $e');
    }
  }
}