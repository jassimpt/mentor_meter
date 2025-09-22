import 'package:flutter/foundation.dart';
import 'package:web_scoket/features/MentorMeter/modules/scheduleform/model/schedule_model.dart';
import 'package:web_scoket/features/MentorMeter/modules/scheduleform/service/schedule_service.dart';

enum ScheduleState {
  idle,
  loading,
  success,
  error,
}

class ScheduleController extends ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();

  // State management
  ScheduleState _state = ScheduleState.idle;
  ScheduleState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ScheduleState.loading;
  bool get hasError => _state == ScheduleState.error;
  bool get isSuccess => _state == ScheduleState.success;

  // Data storage
  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> get schedules => [..._schedules];

  ScheduleModel? _currentSchedule;
  ScheduleModel? get currentSchedule => _currentSchedule;

  // Private method to set state and notify listeners
  void _setState(ScheduleState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Create a new schedule
  Future<bool> createSchedule({
    required String mentorName,
    required String internName,
    required DateTime scheduleDate,
    required String scheduleTime,
    required String sessionTopic,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final schedule = ScheduleModel(
        userId: '',
        mentorName: mentorName,
        internName: internName,
        scheduleDate: scheduleDate,
        scheduleTime: scheduleTime,
        sessionTopic: sessionTopic,
      );

      final createdSchedule = await _scheduleService.createSchedule(schedule);

      // Add to local list
      _schedules.insert(0, createdSchedule);

      _setState(ScheduleState.success);
      return true;
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
      return false;
    }
  }

  /// Fetch all schedules
  Future<void> fetchSchedules({
    int? limit,
    int? offset,
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final fetchedSchedules = await _scheduleService.getSchedules(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        ascending: ascending,
      );

      _schedules = fetchedSchedules;
      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Fetch a specific schedule by ID
  Future<void> fetchScheduleById(String scheduleId) async {
    try {
      _setState(ScheduleState.loading);

      final schedule = await _scheduleService.getScheduleById(scheduleId);
      _currentSchedule = schedule;

      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Update an existing schedule
  Future<bool> updateSchedule({
    required String scheduleId,
    required String mentorName,
    required String internName,
    required DateTime scheduleDate,
    required String scheduleTime,
    required String sessionTopic,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final updatedSchedule = ScheduleModel(
        userId: '',
        mentorName: mentorName,
        internName: internName,
        scheduleDate: scheduleDate,
        scheduleTime: scheduleTime,
        sessionTopic: sessionTopic,
      );

      final result = await _scheduleService.updateSchedule(scheduleId, updatedSchedule);

      // Update in local list
      final index = _schedules.indexWhere((schedule) => schedule.id == scheduleId);
      if (index != -1) {
        _schedules[index] = result;
      }

      _setState(ScheduleState.success);
      return true;
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
      return false;
    }
  }

  /// Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      _setState(ScheduleState.loading);

      await _scheduleService.deleteSchedule(scheduleId);

      // Remove from local list
      _schedules.removeWhere((schedule) => schedule.id == scheduleId);

      _setState(ScheduleState.success);
      return true;
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
      return false;
    }
  }

  /// Search schedules
  Future<void> searchSchedules(
    String searchTerm, {
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final searchResults = await _scheduleService.searchSchedules(
        searchTerm,
        orderBy: orderBy,
        ascending: ascending,
      );

      _schedules = searchResults;
      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Fetch schedules by date range
  Future<void> fetchSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final dateRangeSchedules = await _scheduleService.getSchedulesByDateRange(
        startDate,
        endDate,
        orderBy: orderBy,
        ascending: ascending,
      );

      _schedules = dateRangeSchedules;
      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Fetch upcoming schedules
  Future<void> fetchUpcomingSchedules({
    int? limit,
    String orderBy = 'schedule_date',
    bool ascending = true,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final upcomingSchedules = await _scheduleService.getUpcomingSchedules(
        limit: limit,
        orderBy: orderBy,
        ascending: ascending,
      );

      _schedules = upcomingSchedules;
      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Fetch past schedules
  Future<void> fetchPastSchedules({
    int? limit,
    String orderBy = 'schedule_date',
    bool ascending = false,
  }) async {
    try {
      _setState(ScheduleState.loading);

      final pastSchedules = await _scheduleService.getPastSchedules(
        limit: limit,
        orderBy: orderBy,
        ascending: ascending,
      );

      _schedules = pastSchedules;
      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Fetch today's schedules
  Future<void> fetchTodaySchedules() async {
    try {
      _setState(ScheduleState.loading);

      final todaySchedules = await _scheduleService.getTodaySchedules();

      _schedules = todaySchedules;
      _setState(ScheduleState.success);
    } catch (e) {
      _setState(ScheduleState.error, error: e.toString());
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == ScheduleState.error) {
      _setState(ScheduleState.idle);
    }
  }

  /// Reset controller state
  void reset() {
    _schedules.clear();
    _currentSchedule = null;
    _setState(ScheduleState.idle);
  }

  /// Refresh data (fetch schedules again)
  Future<void> refresh() async {
    await fetchSchedules();
  }

  // Utility methods

  /// Get schedules count
  int get schedulesCount => _schedules.length;

  /// Check if schedules list is empty
  bool get isEmpty => _schedules.isEmpty;

  /// Get upcoming schedules from loaded schedules
  List<ScheduleModel> get upcomingSchedules {
    final now = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.scheduleDateTimeComplete.isAfter(now);
    }).toList();
  }

  /// Get past schedules from loaded schedules
  List<ScheduleModel> get pastSchedules {
    final now = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.scheduleDateTimeComplete.isBefore(now);
    }).toList();
  }

  /// Get today's schedules from loaded schedules
  List<ScheduleModel> get todaySchedules {
    final now = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.scheduleDate.year == now.year &&
             schedule.scheduleDate.month == now.month &&
             schedule.scheduleDate.day == now.day;
    }).toList();
  }

  /// Get schedules for a specific month
  List<ScheduleModel> getSchedulesForMonth(DateTime month) {
    return _schedules.where((schedule) {
      return schedule.scheduleDate.year == month.year &&
          schedule.scheduleDate.month == month.month;
    }).toList();
  }

  /// Get schedules for a specific date
  List<ScheduleModel> getSchedulesForDate(DateTime date) {
    return _schedules.where((schedule) {
      return schedule.scheduleDate.year == date.year &&
          schedule.scheduleDate.month == date.month &&
          schedule.scheduleDate.day == date.day;
    }).toList();
  }

  /// Get total schedules this month
  int get totalSchedulesThisMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    return _schedules.where((schedule) {
      return schedule.scheduleDate.year == thisMonth.year &&
          schedule.scheduleDate.month == thisMonth.month;
    }).length;
  }

  /// Get total schedules today
  int get totalSchedulesToday {
    final today = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.scheduleDate.year == today.year &&
          schedule.scheduleDate.month == today.month &&
          schedule.scheduleDate.day == today.day;
    }).length;
  }

  /// Get next upcoming schedule
  ScheduleModel? get nextUpcomingSchedule {
    final upcoming = upcomingSchedules;
    if (upcoming.isEmpty) return null;
    
    upcoming.sort((a, b) => a.scheduleDateTimeComplete.compareTo(b.scheduleDateTimeComplete));
    return upcoming.first;
  }

  @override
  void dispose() {
    super.dispose();
  }
}