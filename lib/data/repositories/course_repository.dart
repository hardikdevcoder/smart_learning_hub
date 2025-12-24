import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/services/firebase_service.dart';
import '../../core/values/app_constants.dart';
import '../models/course_model.dart';

class CourseRepository extends GetxService {
  final _firestore = FirebaseService.to.firestore;

  CollectionReference get _coursesCollection => _firestore.collection(AppConstants.coursesCollection);

  // Create Course
  Future<String> createCourse(CourseModel course) async {
    try {
      final docRef = await _coursesCollection.add(course.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating course: $e');
      rethrow;
    }
  }

  // Get Course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _coursesCollection.doc(courseId).get();
      if (!doc.exists) return null;
      return CourseModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting course: $e');
      rethrow;
    }
  }

  // Get All Published Courses
  Future<List<CourseModel>> getPublishedCourses() async {
    try {
      final snapshot = await _coursesCollection.where('isPublished', isEqualTo: true).orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting published courses: $e');
      rethrow;
    }
  }

  // Get All Courses (Admin)
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final snapshot = await _coursesCollection.orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all courses: $e');
      rethrow;
    }
  }

  // Update Course
  Future<void> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _coursesCollection.doc(courseId).update(data);
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  // Delete Course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _coursesCollection.doc(courseId).delete();

      // Delete all content associated with this course
      final contentSnapshot = await _firestore.collection(AppConstants.contentCollection).where('courseId', isEqualTo: courseId).get();

      for (var doc in contentSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  // Search Courses
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final snapshot = await _coursesCollection.where('isPublished', isEqualTo: true).orderBy('title').startAt([query]).endAt([query + '\uf8ff']).get();

      return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

  // Get Courses by Category
  Future<List<CourseModel>> getCoursesByCategory(String category) async {
    try {
      final snapshot = await _coursesCollection.where('isPublished', isEqualTo: true).where('category', isEqualTo: category).orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting courses by category: $e');
      rethrow;
    }
  }

  // Stream Courses
  Stream<List<CourseModel>> streamPublishedCourses() {
    return _coursesCollection
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList());
  }

  // Increment Enrolled Count
  Future<void> incrementEnrolledCount(String courseId) async {
    try {
      await _coursesCollection.doc(courseId).update({'enrolledCount': FieldValue.increment(1)});
    } catch (e) {
      print('Error incrementing enrolled count: $e');
      rethrow;
    }
  }
}
