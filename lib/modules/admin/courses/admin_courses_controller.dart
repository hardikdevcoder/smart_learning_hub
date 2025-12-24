import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';

class AdminCoursesController extends GetxController {
  final _courseRepo = Get.find<CourseRepository>();
  final _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final courses = <CourseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      isLoading.value = true;
      final allCourses = await _courseRepo.getAllCourses();
      courses.value = allCourses;
    } catch (e) {
      print('Error loading courses: $e');
      Get.snackbar('Error', 'Failed to load courses');
    } finally {
      isLoading.value = false;
    }
  }

  void showCreateCourseDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final categoryController = TextEditingController();
    final tagsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Create New Course'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title *',
                    hintText: 'e.g., Introduction to Flutter',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Brief course description',
                  ),
                  maxLines: 3,
                  validator: (v) => v?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    hintText: 'e.g., Programming, Design',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Category is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'flutter, mobile, development',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back();
                await _createCourse(
                  titleController.text,
                  descController.text,
                  categoryController.text,
                  tagsController.text,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCourse(
    String title,
    String description,
    String category,
    String tagsStr,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final tags = tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      final course = CourseModel(
        id: '',
        title: title,
        description: description,
        thumbnail: '', // TODO: Add thumbnail upload
        category: category,
        tags: tags,
        totalContent: 0,
        totalVideos: 0,
        totalPDFs: 0,
        totalPPTs: 0,
        totalMCQs: 0,
        createdBy: _authService.user?.uid ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublished: false,
      );

      final courseId = await _courseRepo.createCourse(course);
      Get.back(); // Close loading

      Get.snackbar(
        'Success',
        'Course created successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadCourses();
      manageContent(courseId);
    } catch (e) {
      Get.back(); // Close loading
      print('Error creating course: $e');
      Get.snackbar('Error', 'Failed to create course');
    }
  }

  void editCourse(String courseId) {
    final course = courses.firstWhere((c) => c.id == courseId);
    final titleController = TextEditingController(text: course.title);
    final descController = TextEditingController(text: course.description);
    final categoryController = TextEditingController(text: course.category);
    final tagsController = TextEditingController(text: course.tags.join(', '));
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Course Title *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description *'),
                  maxLines: 3,
                  validator: (v) => v?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Category is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back();
                await _updateCourse(
                  courseId,
                  titleController.text,
                  descController.text,
                  categoryController.text,
                  tagsController.text,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCourse(
    String courseId,
    String title,
    String description,
    String category,
    String tagsStr,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final tags = tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      await _courseRepo.updateCourse(courseId, {
        'title': title,
        'description': description,
        'category': category,
        'tags': tags,
      });

      Get.back();
      Get.snackbar(
        'Success',
        'Course updated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadCourses();
    } catch (e) {
      Get.back();
      print('Error updating course: $e');
      Get.snackbar('Error', 'Failed to update course');
    }
  }

  Future<void> togglePublishStatus(String courseId, bool isPublished) async {
    try {
      await _courseRepo.updateCourse(courseId, {
        'isPublished': !isPublished,
      });

      Get.snackbar(
        'Success',
        isPublished ? 'Course unpublished' : 'Course published',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadCourses();
    } catch (e) {
      print('Error toggling publish status: $e');
      Get.snackbar('Error', 'Failed to update course status');
    }
  }

  Future<void> duplicateCourse(String courseId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final course = courses.firstWhere((c) => c.id == courseId);
      final newCourse = course.copyWith(
        id: '',
        title: '${course.title} (Copy)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublished: false,
        enrolledCount: 0,
      );

      await _courseRepo.createCourse(newCourse);
      Get.back();

      Get.snackbar(
        'Success',
        'Course duplicated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadCourses();
    } catch (e) {
      Get.back();
      print('Error duplicating course: $e');
      Get.snackbar('Error', 'Failed to duplicate course');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDelete(courseId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(String courseId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _courseRepo.deleteCourse(courseId);
      Get.back();

      Get.snackbar(
        'Success',
        'Course deleted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadCourses();
    } catch (e) {
      Get.back();
      print('Error deleting course: $e');
      Get.snackbar('Error', 'Failed to delete course');
    }
  }

  void manageContent(String courseId) {
    Get.toNamed('/admin/content/$courseId');
  }

  void viewCourseDetails(String courseId) {
    manageContent(courseId);
  }

  void showSearchDialog() {
    final searchController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Search Courses'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Enter course name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Get.back();
            _searchCourses(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _searchCourses(searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchCourses(String query) async {
    if (query.isEmpty) {
      await loadCourses();
      return;
    }

    try {
      isLoading.value = true;
      final results = await _courseRepo.searchCourses(query);
      courses.value = results;
    } catch (e) {
      print('Error searching courses: $e');
      Get.snackbar('Error', 'Failed to search courses');
    } finally {
      isLoading.value = false;
    }
  }
}
