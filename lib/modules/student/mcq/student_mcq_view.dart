import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import 'student_mcq_controller.dart';

class StudentMCQView extends GetView<StudentMCQController> {
  const StudentMCQView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.mcq.value?.title ?? 'Quiz')),
        actions: [
          Obx(() {
            if (controller.isQuizStarted.value && !controller.isQuizCompleted.value && controller.mcq.value!.timeLimit > 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: controller.timeRemaining.value < 300 ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: controller.timeRemaining.value < 300 ? AppColors.error : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.timeRemainingFormatted,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: controller.timeRemaining.value < 300 ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.mcq.value == null) {
          return const Center(child: Text('Quiz not found'));
        }

        if (!controller.isQuizStarted.value) {
          return _buildStartScreen();
        }

        return _buildQuizScreen();
      }),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_rounded,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              controller.mcq.value!.title,
              style: Get.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              controller.mcq.value!.description,
              style: Get.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.startQuiz,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.quiz,
              'Questions',
              '${controller.mcq.value!.totalQuestions}',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.timer,
              'Time Limit',
              controller.mcq.value!.timeLimit > 0 ? '${controller.mcq.value!.timeLimit} minutes' : 'No limit',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.grade,
              'Passing Score',
              '${controller.mcq.value!.passingScore}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Get.textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: Obx(() => _buildQuestionCard()),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${controller.currentQuestionIndex.value + 1} of ${controller.totalQuestions}',
                    style: Get.textTheme.titleMedium,
                  ),
                  Text(
                    '${controller.answeredCount} / ${controller.totalQuestions} answered',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (controller.currentQuestionIndex.value + 1) / controller.totalQuestions,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ));
  }

  Widget _buildQuestionCard() {
    final question = controller.mcq.value!.questions[controller.currentQuestionIndex.value];
    final questionIndex = controller.currentQuestionIndex.value;
    final selectedAnswer = controller.getSelectedAnswer(questionIndex);
    final isCompleted = controller.isQuizCompleted.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.question,
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ...List.generate(4, (index) {
                final isSelected = selectedAnswer == index;
                final isCorrect = question.correctAnswer == index;

                Color? backgroundColor;
                Color? borderColor;

                if (isCompleted) {
                  if (isCorrect) {
                    backgroundColor = AppColors.success.withOpacity(0.1);
                    borderColor = AppColors.success;
                  } else if (isSelected) {
                    backgroundColor = AppColors.error.withOpacity(0.1);
                    borderColor = AppColors.error;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: isCompleted ? null : () => controller.selectAnswer(questionIndex, index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor ?? (isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white),
                        border: Border.all(
                          color: borderColor ?? (isSelected ? AppColors.primary : Colors.grey.shade300),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: Get.textTheme.bodyLarge,
                            ),
                          ),
                          if (isCompleted)
                            Icon(
                              isCorrect ? Icons.check_circle : (isSelected ? Icons.cancel : Icons.circle_outlined),
                              color: isCorrect ? AppColors.success : (isSelected ? AppColors.error : Colors.transparent),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (isCompleted && question.explanation != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Explanation',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(question.explanation!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Obx(() => Container(
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
              if (controller.currentQuestionIndex.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousQuestion,
                    child: const Text('Previous'),
                  ),
                ),
              if (controller.currentQuestionIndex.value > 0) const SizedBox(width: 12),
              Expanded(
                child: controller.currentQuestionIndex.value < controller.totalQuestions - 1
                    ? ElevatedButton(
                        onPressed: controller.nextQuestion,
                        child: const Text('Next'),
                      )
                    : ElevatedButton(
                        onPressed: controller.isQuizCompleted.value ? null : () => controller.submitQuiz(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                        child: const Text('Submit Quiz'),
                      ),
              ),
            ],
          ),
        ));
  }
}
