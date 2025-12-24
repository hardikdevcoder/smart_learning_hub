import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../widgets/ppt_viewer_widget.dart';
import '../../widgets/video_player_widget.dart';
import 'course_learning_controller.dart';

class CourseLearningView extends GetView<CourseLearningController> {
  const CourseLearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.course.value?.title ?? 'Course')),
        actions: [
          Obx(() {
            final progress = controller.progressPercentage;
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$progress%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.contents.isEmpty) {
          return _buildEmptyState();
        }

        return Row(
          children: [
            // Content List Sidebar (1/3 width)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: _buildContentList(),
            ),
            // Content Viewer (2/3 width)
            Expanded(
              child: _buildContentViewer(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContentList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Content',
                  style: Get.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final completed = controller.completedCount;
                  final total = controller.totalCount;
                  return Text(
                    '$completed / $total completed',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.contents.length,
                  itemBuilder: (context, index) {
                    final content = controller.contents[index];
                    final isSelected = controller.selectedContent.value?.id == content.id;
                    final isCompleted = controller.isContentCompleted(content.id);

                    return _buildContentListItem(
                      content,
                      isSelected,
                      isCompleted,
                      index + 1,
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildContentListItem(
    content,
    bool isSelected,
    bool isCompleted,
    int order,
  ) {
    final color = _getColorForType(content.contentType);
    final icon = _getIconForType(content.contentType);

    return InkWell(
      onTap: () => controller.selectContent(content),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (content.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      content.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentViewer() {
    return Obx(() {
      final content = controller.selectedContent.value;
      if (content == null) {
        return const Center(
          child: Text('Select content to start learning'),
        );
      }

      return Column(
        children: [
          Expanded(
            child: _buildContentDisplay(content),
          ),
          _buildControlBar(content),
        ],
      );
    });
  }

  Widget _buildContentDisplay(content) {
    switch (content.contentType) {
      case AppConstants.contentTypeVideo:
        return VideoPlayerWidget(url: content.url);
      case AppConstants.contentTypePDF:
        return PDFViewerWidget(url: content.url, title: content.title);
      case AppConstants.contentTypePPT:
        return PPTViewerWidget(url: content.url, title: content.title);
      case AppConstants.contentTypeMCQ:
        return _buildMCQPlaceholder(content);
      default:
        return _buildUnsupportedType(content);
    }
  }

  Widget _buildControlBar(content) {
    final isCompleted = controller.isContentCompleted(content.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  content.title,
                  style: Get.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (content.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    content.description,
                    style: Get.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: controller.markContentCompleted,
              icon: const Icon(Icons.check),
              label: const Text(
                'Mark as Complete',
                style: (TextStyle(fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMCQPlaceholder(content) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: AppColors.mcqColor),
          const SizedBox(height: 16),
          Text(
            'MCQ Quiz',
            style: Get.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Quiz feature coming soon!',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedType(content) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Unsupported Content Type',
            style: Get.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            content.contentType,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: AppColors.textHint),
          const SizedBox(height: 24),
          Text(
            'No Content Available',
            style: Get.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'This course doesn\'t have any content yet',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case AppConstants.contentTypeVideo:
        return AppColors.videoColor;
      case AppConstants.contentTypePDF:
        return AppColors.pdfColor;
      case AppConstants.contentTypePPT:
        return AppColors.pptColor;
      case AppConstants.contentTypeMCQ:
        return AppColors.mcqColor;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case AppConstants.contentTypeVideo:
        return Icons.play_circle_outline;
      case AppConstants.contentTypePDF:
        return Icons.picture_as_pdf_outlined;
      case AppConstants.contentTypePPT:
        return Icons.slideshow_outlined;
      case AppConstants.contentTypeMCQ:
        return Icons.quiz_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}
