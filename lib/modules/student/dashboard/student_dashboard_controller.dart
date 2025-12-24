import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/enrollment_repository.dart';

class StudentDashboardController extends GetxController {
  final _courseRepo = Get.find<CourseRepository>();
  final _enrollmentRepo = Get.find<EnrollmentRepository>();
  final _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final allCourses = <CourseModel>[].obs;
  final enrolledCourses = <CourseModel>[].obs;
  final enrollments = <EnrollmentModel>[].obs;
  final selectedTab = 0.obs; // 0: Explore, 1: My Courses

  String get userId => _authService.user?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Load all published courses
      final courses = await _courseRepo.getPublishedCourses();
      allCourses.value = courses;

      // Load user enrollments
      await loadEnrollments();
    } catch (e) {
      print('Error loading dashboard data: $e');
      Get.snackbar('Error', 'Failed to load courses');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEnrollments() async {
    try {
      final userEnrollments = await _enrollmentRepo.getUserEnrollments(userId);
      enrollments.value = userEnrollments;

      // Get enrolled course details
      final enrolledCourseIds = userEnrollments.map((e) => e.courseId).toList();
      final enrolled = allCourses.where((course) => enrolledCourseIds.contains(course.id)).toList();
      enrolledCourses.value = enrolled;
    } catch (e) {
      print('Error loading enrollments: $e');
    }
  }

  List<CourseModel> get availableCourses {
    final enrolledIds = enrollments.map((e) => e.courseId).toList();
    return allCourses.where((course) => !enrolledIds.contains(course.id)).toList();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> enrollInCourse(CourseModel course) async {
    try {
      // Check if already enrolled
      final isEnrolled = await _enrollmentRepo.isEnrolled(userId, course.id);
      if (isEnrolled) {
        Get.snackbar('Info', 'You are already enrolled in this course');
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final enrollment = EnrollmentModel(
        id: '',
        userId: userId,
        courseId: course.id,
        enrolledAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
        totalContent: course.totalContent,
      );

      await _enrollmentRepo.enrollInCourse(enrollment);

      // Increment enrolled count
      await _courseRepo.incrementEnrolledCount(course.id);

      Get.back(); // Close loading

      Get.snackbar(
        'Success',
        'Successfully enrolled in ${course.title}',
        duration: const Duration(seconds: 2),
      );

      await loadEnrollments();
      selectedTab.value = 1; // Switch to My Courses tab
    } catch (e) {
      Get.back(); // Close loading
      print('Error enrolling: $e');
      Get.snackbar('Error', 'Failed to enroll in course');
    }
  }

  void openCourse(CourseModel course) {
    // Navigate to course learning screen
    Get.toNamed(
      '/student/course/${course.id}',
      arguments: {'userId': userId},
    );
  }

  EnrollmentModel? getEnrollment(String courseId) {
    try {
      return enrollments.firstWhere((e) => e.courseId == courseId);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../core/services/auth_service.dart';
// import '../../../data/models/course_model.dart';
// import '../../../data/models/enrollment_model.dart';
// import '../../../data/repositories/course_repository.dart';
// import '../../../data/repositories/enrollment_repository.dart';
//
// class StudentDashboardController extends GetxController {
//   final _courseRepo = Get.find<CourseRepository>();
//   final _enrollmentRepo = Get.find<EnrollmentRepository>();
//   final _authService = Get.find<AuthService>();
//
//   final isLoading = false.obs;
//   final allCourses = <CourseModel>[].obs;
//   final enrolledCourses = <CourseModel>[].obs;
//   final enrollments = <EnrollmentModel>[].obs;
//   final selectedTab = 0.obs; // 0: Explore, 1: My Courses
//
//   String get userId => _authService.user?.uid ?? '';
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadData();
//   }
//
//   Future<void> loadData() async {
//     try {
//       isLoading.value = true;
//
//       // Load all published courses
//       final courses = await _courseRepo.getPublishedCourses();
//       allCourses.value = courses;
//
//       // Load user enrollments
//       await loadEnrollments();
//     } catch (e) {
//       print('Error loading dashboard data: $e');
//       Get.snackbar('Error', 'Failed to load courses');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadEnrollments() async {
//     try {
//       final userEnrollments = await _enrollmentRepo.getUserEnrollments(userId);
//       enrollments.value = userEnrollments;
//
//       // Get enrolled course details
//       final enrolledCourseIds = userEnrollments.map((e) => e.courseId).toList();
//       final enrolled = allCourses.where((course) => enrolledCourseIds.contains(course.id)).toList();
//       enrolledCourses.value = enrolled;
//     } catch (e) {
//       print('Error loading enrollments: $e');
//     }
//   }
//
//   List<CourseModel> get availableCourses {
//     final enrolledIds = enrollments.map((e) => e.courseId).toList();
//     return allCourses.where((course) => !enrolledIds.contains(course.id)).toList();
//   }
//
//   void changeTab(int index) {
//     selectedTab.value = index;
//   }
//
//   Future<void> enrollInCourse(CourseModel course) async {
//     try {
//       // Check if already enrolled
//       final isEnrolled = await _enrollmentRepo.isEnrolled(userId, course.id);
//       if (isEnrolled) {
//         Get.snackbar('Info', 'You are already enrolled in this course');
//         return;
//       }
//
//       Get.dialog(
//         const Center(
//           child: CircularProgressIndicator(),
//         ),
//         barrierDismissible: false,
//       );
//
//       final enrollment = EnrollmentModel(
//         id: '',
//         userId: userId,
//         courseId: course.id,
//         enrolledAt: DateTime.now(),
//         lastAccessedAt: DateTime.now(),
//         totalContent: course.totalContent,
//       );
//
//       await _enrollmentRepo.enrollInCourse(enrollment);
//
//       // Increment enrolled count
//       await _courseRepo.incrementEnrolledCount(course.id);
//
//       Get.back(); // Close loading
//
//       Get.snackbar(
//         'Success',
//         'Successfully enrolled in ${course.title}',
//         duration: const Duration(seconds: 2),
//       );
//
//       await loadEnrollments();
//       selectedTab.value = 1; // Switch to My Courses tab
//     } catch (e) {
//       Get.back(); // Close loading
//       print('Error enrolling: $e');
//       Get.snackbar('Error', 'Failed to enroll in course');
//     }
//   }
//
//   void openCourse(CourseModel course) {
//     // Navigate to course learning screen
//     Get.toNamed(
//       '/student/course/${course.id}',
//       arguments: {'userId': userId},
//     );
//   }
//
//   EnrollmentModel? getEnrollment(String courseId) {
//     try {
//       return enrollments.firstWhere((e) => e.courseId == courseId);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<void> refreshData() async {
//     await loadData();
//   }
// }
