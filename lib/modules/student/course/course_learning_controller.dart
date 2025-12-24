import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/enrollment_repository.dart';

class CourseLearningController extends GetxController {
  final _courseRepo = Get.find<CourseRepository>();
  final _contentRepo = Get.find<ContentRepository>();
  final _enrollmentRepo = Get.find<EnrollmentRepository>();

  final isLoading = false.obs;
  final course = Rx<CourseModel?>(null);
  final contents = <ContentModel>[].obs;
  final enrollment = Rx<EnrollmentModel?>(null);
  final selectedContent = Rx<ContentModel?>(null);

  String? courseId;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    courseId = Get.parameters['courseId'];
    userId = Get.arguments?['userId'];

    if (courseId != null && userId != null) {
      loadCourseData();
    }
  }

  Future<void> loadCourseData() async {
    try {
      isLoading.value = true;

      // Load course details
      final courseData = await _courseRepo.getCourseById(courseId!);
      course.value = courseData;

      // Load course content
      final courseContent = await _contentRepo.getContentByCourse(courseId!);
      contents.value = courseContent;

      // Load enrollment data
      final enrollmentData = await _enrollmentRepo.getEnrollment(userId!, courseId!);
      enrollment.value = enrollmentData;

      // Select first incomplete content or first content
      if (contents.isNotEmpty) {
        final firstIncomplete = contents.firstWhere(
          (c) => !(enrollmentData?.isContentCompleted(c.id) ?? false),
          orElse: () => contents.first,
        );
        selectedContent.value = firstIncomplete;
      }
    } catch (e) {
      print('Error loading course data: $e');
      Get.snackbar('Error', 'Failed to load course');
    } finally {
      isLoading.value = false;
    }
  }

  void selectContent(ContentModel content) {
    selectedContent.value = content;
    _updateLastAccessed();
  }

  Future<void> markContentCompleted() async {
    if (selectedContent.value == null || enrollment.value == null) return;

    try {
      final contentId = selectedContent.value!.id;
      final enrollmentId = enrollment.value!.id;

      // Check if already completed
      if (enrollment.value!.isContentCompleted(contentId)) {
        Get.snackbar(
          'Info',
          'This content is already marked as completed',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _enrollmentRepo.markContentCompleted(enrollmentId, contentId);

      // Reload enrollment data
      final updatedEnrollment = await _enrollmentRepo.getEnrollment(userId!, courseId!);
      enrollment.value = updatedEnrollment;

      Get.back(); // Close loading

      // Show success message
      Get.snackbar(
        'Success',
        'Content marked as completed!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Check if course is completed
      if (updatedEnrollment?.isCompleted ?? false) {
        _showCourseCompletedDialog();
      } else {
        // Move to next content
        _selectNextContent();
      }
    } catch (e) {
      Get.back(); // Close loading
      print('Error marking content completed: $e');
      Get.snackbar('Error', 'Failed to mark content as completed');
    }
  }

  void _selectNextContent() {
    final currentIndex = contents.indexWhere((c) => c.id == selectedContent.value?.id);
    if (currentIndex < contents.length - 1) {
      selectedContent.value = contents[currentIndex + 1];
    }
  }

  Future<void> _updateLastAccessed() async {
    if (enrollment.value != null) {
      try {
        await _enrollmentRepo.updateLastAccessed(enrollment.value!.id);
      } catch (e) {
        print('Error updating last accessed: $e');
      }
    }
  }

  void _showCourseCompletedDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.success, size: 32),
            const SizedBox(width: 12),
            const Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You have completed this course!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              course.value?.title ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Return to dashboard
            },
            child: const Text('Back to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Reviewing'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  bool isContentCompleted(String contentId) {
    return enrollment.value?.isContentCompleted(contentId) ?? false;
  }

  int get completedCount => enrollment.value?.completedContent ?? 0;
  int get totalCount => enrollment.value?.totalContent ?? 0;
  int get progressPercentage => enrollment.value?.progress ?? 0;
}
