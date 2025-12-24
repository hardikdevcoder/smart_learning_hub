import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import 'admin_mcq_controller.dart';

class AdminMCQView extends GetView<AdminMCQController> {
  const AdminMCQView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create MCQ Quiz'),
        actions: [
          TextButton.icon(
            onPressed: controller.saveMCQ,
            icon: const Icon(Icons.check, color: Colors.black),
            label: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuizInfo(),
            const SizedBox(height: 24),
            _buildQuestionsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
      ),
    );
  }

  Widget _buildQuizInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz Information', style: Get.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title *',
                hintText: 'e.g., Chapter 1 Quiz',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief quiz description',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.timeLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Time Limit (minutes)',
                      hintText: '30',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: controller.passingScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Passing Score (%)',
                      hintText: '70',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Obx(() {
      if (controller.questions.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions (${controller.questions.length})',
            style: Get.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...List.generate(
            controller.questions.length,
            (index) => _buildQuestionCard(index),
          ),
        ],
      );
    });
  }

  Widget _buildQuestionCard(int index) {
    final question = controller.questions[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${index + 1}',
                    style: Get.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => controller.removeQuestion(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Question *',
                hintText: 'Enter your question here',
              ),
              maxLines: 2,
              onChanged: (value) => controller.updateQuestion(index, value),
            ),
            const SizedBox(height: 16),
            Text('Options:', style: Get.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...List.generate(4, (optIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: optIndex,
                      groupValue: question.correctAnswer,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setCorrectAnswer(index, value);
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Option ${optIndex + 1} *',
                          hintText: 'Enter option',
                        ),
                        onChanged: (value) {
                          controller.updateOption(index, optIndex, value);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Explanation (optional)',
                hintText: 'Explain the correct answer',
              ),
              maxLines: 2,
              onChanged: (value) => controller.updateExplanation(index, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('No Questions Yet', style: Get.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Click the button below to add your first question',
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
