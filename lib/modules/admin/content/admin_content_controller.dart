import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/course_repository.dart';

class AdminContentController extends GetxController {
  final _contentRepo = Get.find<ContentRepository>();
  final _courseRepo = Get.find<CourseRepository>();

  final isLoading = false.obs;
  final contents = <ContentModel>[].obs;
  final course = Rx<CourseModel?>(null);
  final selectedFilter = 'all'.obs; // all, video, pdf, ppt, mcq

  String? courseId;

  @override
  void onInit() {
    super.onInit();
    courseId = Get.parameters['courseId'];
    if (courseId != null) {
      loadData();
    }
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Load course details
      final courseData = await _courseRepo.getCourseById(courseId!);
      course.value = courseData;

      // Load content
      await loadContent();
    } catch (e) {
      print('Error loading data: $e');
      Get.snackbar('Error', 'Failed to load content');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadContent() async {
    try {
      final allContent = await _contentRepo.getContentByCourse(courseId!);
      contents.value = allContent;
      print('Error allContent loading content: $allContent');

      applyFilter();
    } catch (e) {
      print('Error loading content: $e');
      rethrow;
    }
  }

  void applyFilter() {
    if (selectedFilter.value == 'all') {
      return;
    }
    // Filter will be applied in the view using Obx
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<ContentModel> get filteredContents {
    if (selectedFilter.value == 'all') {
      return contents;
    }
    return contents.where((c) => c.contentType == selectedFilter.value).toList();
  }

  // Add Video Content
  void showAddVideoDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Video'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Video Title *',
                    hintText: 'e.g., Introduction to Flutter',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL *',
                    hintText: 'https://youtube.com/watch?v=...',
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'URL is required';
                    if (!v!.contains('youtube.com') && !v.contains('youtu.be')) {
                      return 'Please enter a valid YouTube URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Use free educational videos from YouTube',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
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
                await _addContent(
                  AppConstants.contentTypeVideo,
                  titleController.text,
                  descController.text,
                  urlController.text,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Add PDF Content
  void showAddPDFDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Add PDF Document'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Document Title *',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'PDF URL *',
                    hintText: 'Direct link to PDF file',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'URL is required' : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Use Google Drive or Dropbox direct links',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
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
                await _addContent(
                  AppConstants.contentTypePDF,
                  titleController.text,
                  descController.text,
                  urlController.text,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Add PPT Content
  void showAddPPTDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Presentation'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Presentation Title *',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'PPT URL *',
                    hintText: 'Link to presentation',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'URL is required' : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Share from Google Slides or SlideShare',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
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
                await _addContent(
                  AppConstants.contentTypePPT,
                  titleController.text,
                  descController.text,
                  urlController.text,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Create MCQ Quiz
  void createMCQQuiz() {
    Get.toNamed('/admin/mcq/create/$courseId');
  }

  Future<void> _addContent(
    String type,
    String title,
    String description,
    String url,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final content = ContentModel(
        id: '',
        courseId: courseId!,
        title: title,
        description: description,
        contentType: type,
        url: url,
        order: contents.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _contentRepo.createContent(content);

      // Update course content count
      await _updateCourseContentCount();

      Get.back(); // Close loading

      Get.snackbar(
        'Success',
        'Content added successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadData();
    } catch (e) {
      Get.back(); // Close loading
      print('Error adding content: $e');
      Get.snackbar('Error', 'Failed to add content');
    }
  }

  Future<void> _updateCourseContentCount() async {
    try {
      final counts = await _contentRepo.getContentCountByCourse(courseId!);

      await _courseRepo.updateCourse(courseId!, {
        'totalContent': counts['total'],
        'totalVideos': counts['videos'],
        'totalPDFs': counts['pdfs'],
        'totalPPTs': counts['ppts'],
        'totalMCQs': counts['mcqs'],
      });
    } catch (e) {
      print('Error updating content count: $e');
    }
  }

  void editContent(ContentModel content) {
    final titleController = TextEditingController(text: content.title);
    final descController = TextEditingController(text: content.description);
    final urlController = TextEditingController(text: content.url);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Content'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'URL *'),
                  validator: (v) => v?.isEmpty ?? true ? 'URL is required' : null,
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
                await _updateContent(
                  content.id,
                  titleController.text,
                  descController.text,
                  urlController.text,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateContent(
    String contentId,
    String title,
    String description,
    String url,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _contentRepo.updateContent(contentId, {
        'title': title,
        'description': description,
        'url': url,
      });

      Get.back();

      Get.snackbar(
        'Success',
        'Content updated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadContent();
    } catch (e) {
      Get.back();
      print('Error updating content: $e');
      Get.snackbar('Error', 'Failed to update content');
    }
  }

  Future<void> deleteContent(String contentId) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Content'),
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDelete(contentId);
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

  Future<void> _performDelete(String contentId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _contentRepo.deleteContent(contentId);
      await _updateCourseContentCount();

      Get.back();

      Get.snackbar(
        'Success',
        'Content deleted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadContent();
    } catch (e) {
      Get.back();
      print('Error deleting content: $e');
      Get.snackbar('Error', 'Failed to delete content');
    }
  }
}
