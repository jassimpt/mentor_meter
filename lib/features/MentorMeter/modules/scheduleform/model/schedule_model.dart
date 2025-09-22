// lib/features/MentorMeter/modules/schedule/models/schedule_model.dart

class ScheduleModel {
  final String? id;
  final String userId;
  final String mentorName;
  final String internName;
  final DateTime scheduleDate;
  final String scheduleTime; // Store as string (HH:mm format)
  final String sessionTopic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleModel({
    this.id,
    required this.userId,
    required this.mentorName,
    required this.internName,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.sessionTopic,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create ScheduleModel from JSON
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      userId: json['user_id'],
      mentorName: json['mentor_name'],
      internName: json['intern_name'],
      scheduleDate: DateTime.parse(json['schedule_date']),
      scheduleTime: json['schedule_time'],
      sessionTopic: json['session_topic'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Convert ScheduleModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mentor_name': mentorName,
      'intern_name': internName,
      'schedule_date': scheduleDate.toIso8601String().split('T')[0], // Date only
      'schedule_time': scheduleTime,
      'session_topic': sessionTopic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to JSON for creating new schedule (without id, createdAt, updatedAt)
  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'mentor_name': mentorName,
      'intern_name': internName,
      'schedule_date': scheduleDate.toIso8601String().split('T')[0], // Date only
      'schedule_time': scheduleTime,
      'session_topic': sessionTopic,
    };
  }

  // Convert to JSON for updating schedule (without user_id, createdAt)
  Map<String, dynamic> toUpdateJson() {
    return {
      'mentor_name': mentorName,
      'intern_name': internName,
      'schedule_date': scheduleDate.toIso8601String().split('T')[0], // Date only
      'schedule_time': scheduleTime,
      'session_topic': sessionTopic,
    };
  }

  // CopyWith method for creating modified copies
  ScheduleModel copyWith({
    String? id,
    String? userId,
    String? mentorName,
    String? internName,
    DateTime? scheduleDate,
    String? scheduleTime,
    String? sessionTopic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mentorName: mentorName ?? this.mentorName,
      internName: internName ?? this.internName,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      sessionTopic: sessionTopic ?? this.sessionTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get DateTime representation of schedule date + time
  DateTime get scheduleDateTimeComplete {
    final timeParts = scheduleTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      hour,
      minute,
    );
  }

  // Helper method to check if schedule is today
  bool get isToday {
    final now = DateTime.now();
    return scheduleDate.year == now.year &&
           scheduleDate.month == now.month &&
           scheduleDate.day == now.day;
  }

  // Helper method to check if schedule is upcoming (future)
  bool get isUpcoming {
    return scheduleDateTimeComplete.isAfter(DateTime.now());
  }

  // Helper method to check if schedule is past
  bool get isPast {
    return scheduleDateTimeComplete.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'ScheduleModel(id: $id, userId: $userId, mentorName: $mentorName, internName: $internName, scheduleDate: $scheduleDate, scheduleTime: $scheduleTime, sessionTopic: $sessionTopic, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleModel &&
        other.id == id &&
        other.userId == userId &&
        other.mentorName == mentorName &&
        other.internName == internName &&
        other.scheduleDate == scheduleDate &&
        other.scheduleTime == scheduleTime &&
        other.sessionTopic == sessionTopic &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      mentorName,
      internName,
      scheduleDate,
      scheduleTime,
      sessionTopic,
      createdAt,
      updatedAt,
    );
  }
}