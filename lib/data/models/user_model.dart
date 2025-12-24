import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'admin' or 'student'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.metadata,
  });

  // From Firebase Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'student',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null ? (data['lastLogin'] as Timestamp).toDate() : null,
      metadata: data['metadata'],
    );
  }

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
      role: json['role'] ?? 'student',
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? (json['lastLogin'] is Timestamp ? (json['lastLogin'] as Timestamp).toDate() : DateTime.parse(json['lastLogin'])) : null,
      metadata: json['metadata'],
    );
  }

  // To JSON for FireStore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'metadata': metadata,
    };
  }

  // To JSON for local storage (without Timestamp)
  Map<String, dynamic> toLocalJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Helper methods
  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  // CopyWith method
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      metadata: metadata ?? this.metadata,
    );
  }
}
