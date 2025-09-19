// lib/features/MentorMeter/modules/review/models/review_model.dart

class ReviewModel {
  final String? id;
  final String userId;
  final String mentorName;
  final String internName;
  final DateTime reviewDate;
  final String reviewTopic;
  final int reviewScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    this.id,
    required this.userId,
    required this.mentorName,
    required this.internName,
    required this.reviewDate,
    required this.reviewTopic,
    required this.reviewScore,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create ReviewModel from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      mentorName: json['mentor_name'],
      internName: json['intern_name'],
      reviewDate: DateTime.parse(json['review_date']),
      reviewTopic: json['review_topic'],
      reviewScore: json['review_score'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Convert ReviewModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mentor_name': mentorName,
      'intern_name': internName,
      'review_date': reviewDate.toIso8601String().split('T')[0], // Date only
      'review_topic': reviewTopic,
      'review_score': reviewScore,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to JSON for creating new review (without id, createdAt, updatedAt)
  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'mentor_name': mentorName,
      'intern_name': internName,
      'review_date': reviewDate.toIso8601String().split('T')[0], // Date only
      'review_topic': reviewTopic,
      'review_score': reviewScore,
    };
  }

  // Convert to JSON for updating review (without user_id, createdAt)
  Map<String, dynamic> toUpdateJson() {
    return {
      'mentor_name': mentorName,
      'intern_name': internName,
      'review_date': reviewDate.toIso8601String().split('T')[0], // Date only
      'review_topic': reviewTopic,
      'review_score': reviewScore,
    };
  }

  // CopyWith method for creating modified copies
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? mentorName,
    String? internName,
    DateTime? reviewDate,
    String? reviewTopic,
    int? reviewScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mentorName: mentorName ?? this.mentorName,
      internName: internName ?? this.internName,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewTopic: reviewTopic ?? this.reviewTopic,
      reviewScore: reviewScore ?? this.reviewScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, userId: $userId, mentorName: $mentorName, internName: $internName, reviewDate: $reviewDate, reviewTopic: $reviewTopic, reviewScore: $reviewScore, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel &&
        other.id == id &&
        other.userId == userId &&
        other.mentorName == mentorName &&
        other.internName == internName &&
        other.reviewDate == reviewDate &&
        other.reviewTopic == reviewTopic &&
        other.reviewScore == reviewScore &&
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
      reviewDate,
      reviewTopic,
      reviewScore,
      createdAt,
      updatedAt,
    );
  }
}