import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String contentType; // video, pdf, ppt, mcq
  final String url;
  final String? thumbnailUrl;
  final int order;
  final int duration; // in seconds for video, 0 for others
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.contentType,
    required this.url,
    this.thumbnailUrl,
    required this.order,
    this.duration = 0,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      contentType: data['contentType'] ?? '',
      url: data['url'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      order: data['order'] ?? 0,
      duration: data['duration'] ?? 0,
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      contentType: json['contentType'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      order: json['order'] ?? 0,
      duration: json['duration'] ?? 0,
      metadata: json['metadata'],
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp ? (json['updatedAt'] as Timestamp).toDate() : DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'contentType': contentType,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'order': order,
      'duration': duration,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isVideo => contentType == 'video';
  bool get isPDF => contentType == 'pdf';
  bool get isPPT => contentType == 'ppt';
  bool get isMCQ => contentType == 'mcq';

  ContentModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? contentType,
    String? url,
    String? thumbnailUrl,
    int? order,
    int? duration,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      order: order ?? this.order,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
