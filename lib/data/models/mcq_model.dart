import 'package:cloud_firestore/cloud_firestore.dart';

class MCQQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer; // Index of correct option (0-3)
  final String? explanation;

  MCQQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    return MCQQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class MCQModel {
  final String id;
  final String contentId;
  final String courseId;
  final String title;
  final String description;
  final List<MCQQuestion> questions;
  final int timeLimit; // in minutes, 0 for no limit
  final int passingScore; // percentage
  final DateTime createdAt;
  final DateTime updatedAt;

  MCQModel({
    required this.id,
    required this.contentId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit = 0,
    this.passingScore = 70,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MCQModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MCQModel(
      id: doc.id,
      contentId: data['contentId'] ?? '',
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>?)?.map((q) => MCQQuestion.fromJson(q as Map<String, dynamic>)).toList() ?? [],
      timeLimit: data['timeLimit'] ?? 0,
      passingScore: data['passingScore'] ?? 70,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory MCQModel.fromJson(Map<String, dynamic> json) {
    return MCQModel(
      id: json['id'] ?? '',
      contentId: json['contentId'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)?.map((q) => MCQQuestion.fromJson(q as Map<String, dynamic>)).toList() ?? [],
      timeLimit: json['timeLimit'] ?? 0,
      passingScore: json['passingScore'] ?? 70,
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp ? (json['updatedAt'] as Timestamp).toDate() : DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get totalQuestions => questions.length;

  MCQModel copyWith({
    String? id,
    String? contentId,
    String? courseId,
    String? title,
    String? description,
    List<MCQQuestion>? questions,
    int? timeLimit,
    int? passingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MCQModel(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      passingScore: passingScore ?? this.passingScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
