import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final DateTime? lastAccessedAt;
  final int progress; // Percentage (0-100)
  final int completedContent;
  final int totalContent;
  final Map<String, bool> completedContentIds; // contentId: true/false
  final bool isCompleted;
  final DateTime? completedAt;

  EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.lastAccessedAt,
    this.progress = 0,
    this.completedContent = 0,
    required this.totalContent,
    Map<String, bool>? completedContentIds,
    this.isCompleted = false,
    this.completedAt,
  }) : completedContentIds = completedContentIds ?? {};

  factory EnrollmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnrollmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
      lastAccessedAt: data['lastAccessedAt'] != null ? (data['lastAccessedAt'] as Timestamp).toDate() : null,
      progress: data['progress'] ?? 0,
      completedContent: data['completedContent'] ?? 0,
      totalContent: data['totalContent'] ?? 0,
      completedContentIds: Map<String, bool>.from(data['completedContentIds'] ?? {}),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
    );
  }

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      enrolledAt: json['enrolledAt'] is Timestamp ? (json['enrolledAt'] as Timestamp).toDate() : DateTime.parse(json['enrolledAt']),
      lastAccessedAt:
          json['lastAccessedAt'] != null ? (json['lastAccessedAt'] is Timestamp ? (json['lastAccessedAt'] as Timestamp).toDate() : DateTime.parse(json['lastAccessedAt'])) : null,
      progress: json['progress'] ?? 0,
      completedContent: json['completedContent'] ?? 0,
      totalContent: json['totalContent'] ?? 0,
      completedContentIds: Map<String, bool>.from(json['completedContentIds'] ?? {}),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? (json['completedAt'] is Timestamp ? (json['completedAt'] as Timestamp).toDate() : DateTime.parse(json['completedAt'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'lastAccessedAt': lastAccessedAt != null ? Timestamp.fromDate(lastAccessedAt!) : null,
      'progress': progress,
      'completedContent': completedContent,
      'totalContent': totalContent,
      'completedContentIds': completedContentIds,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  EnrollmentModel copyWith({
    String? id,
    String? userId,
    String? courseId,
    DateTime? enrolledAt,
    DateTime? lastAccessedAt,
    int? progress,
    int? completedContent,
    int? totalContent,
    Map<String, bool>? completedContentIds,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return EnrollmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      progress: progress ?? this.progress,
      completedContent: completedContent ?? this.completedContent,
      totalContent: totalContent ?? this.totalContent,
      completedContentIds: completedContentIds ?? this.completedContentIds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Calculate progress based on completed content
  int calculateProgress() {
    if (totalContent == 0) return 0;
    return ((completedContent / totalContent) * 100).round();
  }

  // Mark content as completed
  EnrollmentModel markContentCompleted(String contentId) {
    final newCompletedIds = Map<String, bool>.from(completedContentIds);
    newCompletedIds[contentId] = true;

    final newCompletedCount = newCompletedIds.values.where((v) => v).length;
    final newProgress = ((newCompletedCount / totalContent) * 100).round();
    final newIsCompleted = newCompletedCount == totalContent;

    return copyWith(
      completedContentIds: newCompletedIds,
      completedContent: newCompletedCount,
      progress: newProgress,
      isCompleted: newIsCompleted,
      completedAt: newIsCompleted ? DateTime.now() : completedAt,
      lastAccessedAt: DateTime.now(),
    );
  }

  // Check if content is completed
  bool isContentCompleted(String contentId) {
    return completedContentIds[contentId] ?? false;
  }
}
