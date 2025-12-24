import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import 'admin_content_controller.dart';

class AdminContentView extends GetView<AdminContentController> {
  const AdminContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.course.value?.title ?? 'Content')),
        // title: Text('Content'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Obx(() => _buildFilterChips()),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredContents.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredContents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final content = controller.filteredContents[index];
              return _buildContentCard(content);
            },
          ),
        );
      }),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all', Icons.apps),
            const SizedBox(width: 8),
            _buildFilterChip('Videos', AppConstants.contentTypeVideo, Icons.video_library_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('PDFs', AppConstants.contentTypePDF, Icons.picture_as_pdf),
            const SizedBox(width: 8),
            _buildFilterChip('PPTs', AppConstants.contentTypePPT, Icons.slideshow),
            const SizedBox(width: 8),
            _buildFilterChip('MCQs', AppConstants.contentTypeMCQ, Icons.quiz),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = controller.selectedFilter.value == value;
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => controller.changeFilter(value),
      backgroundColor: Colors.white,
      selectedColor: _getColorForType(value).withOpacity(0.2),
      checkmarkColor: _getColorForType(value),
      labelStyle: TextStyle(
        color: isSelected ? _getColorForType(value) : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildContentCard(content) {
    final color = _getColorForType(content.contentType);
    final icon = _getIconForType(content.contentType);

    return Card(
      child: InkWell(
        onTap: () {
          if (content.contentType != AppConstants.contentTypeMCQ) controller.editContent(content);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            content.title,
                            style: Get.textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTypeLabel(content.contentType),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (content.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        content.description,
                        style: Get.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Order: ${content.order + 1}',
                      style: Get.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && content.contentType != AppConstants.contentTypeMCQ) {
                    controller.editContent(content);
                  } else if (value == 'delete') {
                    controller.deleteContent(content.id);
                  }
                },
                itemBuilder: (context) => [
                  if (content.contentType != AppConstants.contentTypeMCQ)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getTypeLabel(String type) {
    switch (type) {
      case AppConstants.contentTypeVideo:
        return 'VIDEO';
      case AppConstants.contentTypePDF:
        return 'PDF';
      case AppConstants.contentTypePPT:
        return 'PPT';
      case AppConstants.contentTypeMCQ:
        return 'MCQ';
      default:
        return 'CONTENT';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'No Content Yet',
              style: Get.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding videos, PDFs, presentations,\nor create MCQ quizzes',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.showAddVideoDialog,
                  icon: const Icon(Icons.video_library),
                  label: const Text('Add Video'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.showAddPDFDialog,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Add PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showAddContentMenu(),
      child: const Icon(Icons.add),
    );
  }

  void _showAddContentMenu() {
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
              leading: const Icon(Icons.video_library, color: AppColors.videoColor),
              title: const Text('Add Video'),
              subtitle: const Text('YouTube video link'),
              onTap: () {
                Get.back();
                controller.showAddVideoDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.pdfColor),
              title: const Text('Add PDF'),
              subtitle: const Text('Document link'),
              onTap: () {
                Get.back();
                controller.showAddPDFDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.slideshow, color: AppColors.pptColor),
              title: const Text('Add Presentation'),
              subtitle: const Text('PPT/Slides link'),
              onTap: () {
                Get.back();
                controller.showAddPPTDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: AppColors.mcqColor),
              title: const Text('Create MCQ Quiz'),
              subtitle: const Text('Multiple choice questions'),
              onTap: () {
                // Get.back();
                controller.createMCQQuiz();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
