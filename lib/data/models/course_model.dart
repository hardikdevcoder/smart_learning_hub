import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String category;
  final List<String> tags;
  final int totalContent;
  final int totalVideos;
  final int totalPDFs;
  final int totalPPTs;
  final int totalMCQs;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int enrolledCount;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.category,
    required this.tags,
    required this.totalContent,
    required this.totalVideos,
    required this.totalPDFs,
    required this.totalPPTs,
    required this.totalMCQs,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
    this.enrolledCount = 0,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      totalContent: data['totalContent'] ?? 0,
      totalVideos: data['totalVideos'] ?? 0,
      totalPDFs: data['totalPDFs'] ?? 0,
      totalPPTs: data['totalPPTs'] ?? 0,
      totalMCQs: data['totalMCQs'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublished: data['isPublished'] ?? false,
      enrolledCount: data['enrolledCount'] ?? 0,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      totalContent: json['totalContent'] ?? 0,
      totalVideos: json['totalVideos'] ?? 0,
      totalPDFs: json['totalPDFs'] ?? 0,
      totalPPTs: json['totalPPTs'] ?? 0,
      totalMCQs: json['totalMCQs'] ?? 0,
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp ? (json['updatedAt'] as Timestamp).toDate() : DateTime.parse(json['updatedAt']),
      isPublished: json['isPublished'] ?? false,
      enrolledCount: json['enrolledCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'category': category,
      'tags': tags,
      'totalContent': totalContent,
      'totalVideos': totalVideos,
      'totalPDFs': totalPDFs,
      'totalPPTs': totalPPTs,
      'totalMCQs': totalMCQs,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'enrolledCount': enrolledCount,
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    String? category,
    List<String>? tags,
    int? totalContent,
    int? totalVideos,
    int? totalPDFs,
    int? totalPPTs,
    int? totalMCQs,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? enrolledCount,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      totalContent: totalContent ?? this.totalContent,
      totalVideos: totalVideos ?? this.totalVideos,
      totalPDFs: totalPDFs ?? this.totalPDFs,
      totalPPTs: totalPPTs ?? this.totalPPTs,
      totalMCQs: totalMCQs ?? this.totalMCQs,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      enrolledCount: enrolledCount ?? this.enrolledCount,
    );
  }
}
