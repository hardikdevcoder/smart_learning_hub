import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/mcq_model.dart';
import '../../../data/repositories/mcq_repository.dart';

class StudentMCQController extends GetxController {
  final _mcqRepo = Get.find<MCQRepository>();

  final isLoading = false.obs;
  final mcq = Rx<MCQModel?>(null);
  final currentQuestionIndex = 0.obs;
  final selectedAnswers = <int, int>{}.obs; // questionIndex: selectedOption
  final isQuizStarted = false.obs;
  final isQuizCompleted = false.obs;
  final timeRemaining = 0.obs; // in seconds
  final score = 0.obs;
  final isPassed = false.obs;

  Timer? _timer;
  String? contentId;

  @override
  void onInit() {
    super.onInit();
    contentId = Get.parameters['contentId'];
    if (contentId != null) {
      loadMCQ();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadMCQ() async {
    try {
      isLoading.value = true;
      final mcqData = await _mcqRepo.getMCQByContentId(contentId!);
      mcq.value = mcqData;
    } catch (e) {
      print('Error loading MCQ: $e');
      Get.snackbar('Error', 'Failed to load quiz');
    } finally {
      isLoading.value = false;
    }
  }

  void startQuiz() {
    isQuizStarted.value = true;
    if (mcq.value!.timeLimit > 0) {
      timeRemaining.value = mcq.value!.timeLimit * 60; // Convert to seconds
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        timer.cancel();
        submitQuiz(autoSubmit: true);
      }
    });
  }

  String get timeRemainingFormatted {
    final minutes = timeRemaining.value ~/ 60;
    final seconds = timeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    selectedAnswers[questionIndex] = optionIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < mcq.value!.questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
  }

  bool get canSubmit => selectedAnswers.length == mcq.value!.questions.length;

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => mcq.value?.questions.length ?? 0;

  void submitQuiz({bool autoSubmit = false}) {
    if (!canSubmit && !autoSubmit) {
      Get.snackbar(
        'Incomplete',
        'Please answer all questions before submitting',
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text(autoSubmit ? 'Time\'s Up!' : 'Submit Quiz?'),
        content: Text(
          autoSubmit ? 'Your time has expired. The quiz will be submitted automatically.' : 'Are you sure you want to submit? You cannot change answers after submission.',
        ),
        actions: autoSubmit
            ? [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _calculateScore();
                  },
                  child: const Text('OK'),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _calculateScore();
                  },
                  child: const Text('Submit'),
                ),
              ],
      ),
      barrierDismissible: false,
    );
  }

  void _calculateScore() {
    _timer?.cancel();

    int correctAnswers = 0;
    for (int i = 0; i < mcq.value!.questions.length; i++) {
      final selectedAnswer = selectedAnswers[i];
      final correctAnswer = mcq.value!.questions[i].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        correctAnswers++;
      }
    }

    score.value = ((correctAnswers / mcq.value!.questions.length) * 100).round();
    isPassed.value = score.value >= mcq.value!.passingScore;
    isQuizCompleted.value = true;

    _showResultDialog();
  }

  void _showResultDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              isPassed.value ? Icons.celebration : Icons.error_outline,
              color: isPassed.value ? AppColors.success : AppColors.warning,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(isPassed.value ? 'Congratulations!' : 'Keep Learning!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${score.value}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: isPassed.value ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPassed.value ? 'You passed the quiz!' : 'You need ${mcq.value!.passingScore}% to pass',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Correct: ${(score.value * totalQuestions / 100).round()} / $totalQuestions',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              currentQuestionIndex.value = 0;
            },
            child: const Text('Review Answers'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back(); // Go back to course
            },
            child: const Text('Done'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  bool isAnswerCorrect(int questionIndex) {
    if (!isQuizCompleted.value) return false;
    final selected = selectedAnswers[questionIndex];
    final correct = mcq.value!.questions[questionIndex].correctAnswer;
    return selected == correct;
  }

  int? getSelectedAnswer(int questionIndex) {
    return selectedAnswers[questionIndex];
  }
}
