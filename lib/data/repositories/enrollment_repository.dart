import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/services/firebase_service.dart';
import '../models/enrollment_model.dart';

class EnrollmentRepository extends GetxService {
  final _firestore = FirebaseService.to.firestore;

  CollectionReference get _enrollmentsCollection => _firestore.collection('enrollments');

  // Enroll in course
  Future<String> enrollInCourse(EnrollmentModel enrollment) async {
    try {
      final docRef = await _enrollmentsCollection.add(enrollment.toJson());
      return docRef.id;
    } catch (e) {
      print('Error enrolling in course: $e');
      rethrow;
    }
  }

  // Check if user is enrolled
  Future<bool> isEnrolled(String userId, String courseId) async {
    try {
      final snapshot = await _enrollmentsCollection.where('userId', isEqualTo: userId).where('courseId', isEqualTo: courseId).limit(1).get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking enrollment: $e');
      return false;
    }
  }

  // Get enrollment by user and course
  Future<EnrollmentModel?> getEnrollment(String userId, String courseId) async {
    try {
      final snapshot = await _enrollmentsCollection.where('userId', isEqualTo: userId).where('courseId', isEqualTo: courseId).limit(1).get();

      if (snapshot.docs.isEmpty) return null;
      return EnrollmentModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting enrollment: $e');
      return null;
    }
  }

  // Get all enrollments for user
  Future<List<EnrollmentModel>> getUserEnrollments(String userId) async {
    try {
      final snapshot = await _enrollmentsCollection.where('userId', isEqualTo: userId).orderBy('enrolledAt', descending: true).get();

      return snapshot.docs.map((doc) => EnrollmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user enrollments: $e');
      rethrow;
    }
  }

  // Get in-progress courses
  Future<List<EnrollmentModel>> getInProgressCourses(String userId) async {
    try {
      final snapshot = await _enrollmentsCollection.where('userId', isEqualTo: userId).where('isCompleted', isEqualTo: false).orderBy('lastAccessedAt', descending: true).get();

      return snapshot.docs.map((doc) => EnrollmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting in-progress courses: $e');
      rethrow;
    }
  }

  // Get completed courses
  Future<List<EnrollmentModel>> getCompletedCourses(String userId) async {
    try {
      final snapshot = await _enrollmentsCollection.where('userId', isEqualTo: userId).where('isCompleted', isEqualTo: true).orderBy('completedAt', descending: true).get();

      return snapshot.docs.map((doc) => EnrollmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting completed courses: $e');
      rethrow;
    }
  }

  // Update enrollment progress
  Future<void> updateProgress(String enrollmentId, int completedContent, Map<String, bool> completedContentIds) async {
    try {
      final enrollment = await _enrollmentsCollection.doc(enrollmentId).get();
      final enrollmentData = EnrollmentModel.fromFirestore(enrollment);

      final progress = enrollmentData.calculateProgress();
      final isCompleted = completedContent == enrollmentData.totalContent;

      await _enrollmentsCollection.doc(enrollmentId).update({
        'completedContent': completedContent,
        'completedContentIds': completedContentIds,
        'progress': progress,
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? Timestamp.now() : null,
        'lastAccessedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating progress: $e');
      rethrow;
    }
  }

  // Mark content as completed
  Future<void> markContentCompleted(String enrollmentId, String contentId) async {
    try {
      final doc = await _enrollmentsCollection.doc(enrollmentId).get();
      final enrollment = EnrollmentModel.fromFirestore(doc);

      final updatedEnrollment = enrollment.markContentCompleted(contentId);

      await _enrollmentsCollection.doc(enrollmentId).update({
        'completedContentIds': updatedEnrollment.completedContentIds,
        'completedContent': updatedEnrollment.completedContent,
        'progress': updatedEnrollment.progress,
        'isCompleted': updatedEnrollment.isCompleted,
        'completedAt': updatedEnrollment.completedAt != null ? Timestamp.fromDate(updatedEnrollment.completedAt!) : null,
        'lastAccessedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error marking content completed: $e');
      rethrow;
    }
  }

  // Update last accessed
  Future<void> updateLastAccessed(String enrollmentId) async {
    try {
      await _enrollmentsCollection.doc(enrollmentId).update({
        'lastAccessedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating last accessed: $e');
      rethrow;
    }
  }

  // Stream user enrollments
  Stream<List<EnrollmentModel>> streamUserEnrollments(String userId) {
    return _enrollmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EnrollmentModel.fromFirestore(doc)).toList());
  }

  // Unenroll from course
  Future<void> unenroll(String enrollmentId) async {
    try {
      await _enrollmentsCollection.doc(enrollmentId).delete();
    } catch (e) {
      print('Error unenrolling: $e');
      rethrow;
    }
  }
}
