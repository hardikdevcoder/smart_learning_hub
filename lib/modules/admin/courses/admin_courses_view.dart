import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import 'admin_courses_controller.dart';

class AdminCoursesView extends GetView<AdminCoursesController> {
  const AdminCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            // onPressed: controller.showSearchDialog,
            onPressed: controller.showCreateCourseDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.courses.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadCourses,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = controller.courses[index];
              return _buildCourseCard(course);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showCreateCourseDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Course'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildCourseCard(course) {
    return Card(
      child: InkWell(
        onTap: () => controller.viewCourseDetails(course.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: Get.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.category,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: course.isPublished ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.isPublished ? 'Published' : 'Draft',
                      style: TextStyle(
                        color: course.isPublished ? AppColors.success : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.description,
                style: Get.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.video_library_rounded,
                    '${course.totalVideos} Videos',
                    AppColors.videoColor,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.picture_as_pdf_rounded,
                    '${course.totalPDFs} PDFs',
                    AppColors.pdfColor,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.people_rounded,
                    '${course.enrolledCount}',
                    AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.editCourse(course.id),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.manageContent(course.id),
                      icon: const Icon(Icons.folder_outlined, size: 18),
                      label: const Text('Content'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showCourseOptions(course),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'No Courses Yet',
              style: Get.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first course and start\nadding learning content',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.showCreateCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create First Course'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseOptions(course) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Course'),
              onTap: () {
                Get.back();
                controller.editCourse(course.id);
              },
            ),
            ListTile(
              leading: Icon(
                course.isPublished ? Icons.visibility_off : Icons.visibility,
                color: AppColors.warning,
              ),
              title: Text(course.isPublished ? 'Unpublish' : 'Publish'),
              onTap: () {
                Get.back();
                controller.togglePublishStatus(course.id, course.isPublished);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_outlined, color: AppColors.info),
              title: const Text('Duplicate Course'),
              onTap: () {
                Get.back();
                controller.duplicateCourse(course.id);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Course',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Get.back();
                controller.deleteCourse(course.id);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
