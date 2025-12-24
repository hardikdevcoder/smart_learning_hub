import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/mcq_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/mcq_repository.dart';

class AdminMCQController extends GetxController {
  final _mcqRepo = Get.find<MCQRepository>();
  final _contentRepo = Get.find<ContentRepository>();
  final _courseRepo = Get.find<CourseRepository>();

  final isLoading = false.obs;
  final questions = <MCQQuestion>[].obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeLimitController = TextEditingController(text: '30');
  final passingScoreController = TextEditingController(text: '70');

  String? courseId;

  @override
  void onInit() {
    super.onInit();
    courseId = Get.parameters['courseId'];
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    timeLimitController.dispose();
    passingScoreController.dispose();
    super.onClose();
  }

  void addQuestion() {
    questions.add(
      MCQQuestion(
        question: '',
        options: ['', '', '', ''],
        correctAnswer: 0,
      ),
    );
  }

  void removeQuestion(int index) {
    if (questions.length > 1) {
      questions.removeAt(index);
    } else {
      Get.snackbar('Info', 'Quiz must have at least one question');
    }
  }

  void updateQuestion(int index, String question) {
    final q = questions[index];
    questions[index] = MCQQuestion(
      question: question,
      options: q.options,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
    );
  }

  void updateOption(int qIndex, int optIndex, String value) {
    final q = questions[qIndex];
    final newOptions = List<String>.from(q.options);
    newOptions[optIndex] = value;

    questions[qIndex] = MCQQuestion(
      question: q.question,
      options: newOptions,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
    );
  }

  void setCorrectAnswer(int qIndex, int answerIndex) {
    final q = questions[qIndex];
    questions[qIndex] = MCQQuestion(
      question: q.question,
      options: q.options,
      correctAnswer: answerIndex,
      explanation: q.explanation,
    );
  }

  void updateExplanation(int qIndex, String explanation) {
    final q = questions[qIndex];
    questions[qIndex] = MCQQuestion(
      question: q.question,
      options: q.options,
      correctAnswer: q.correctAnswer,
      explanation: explanation,
    );
  }

  Future<void> saveMCQ() async {
    // Validation
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter quiz title');
      return;
    }

    if (questions.isEmpty) {
      Get.snackbar('Error', 'Please add at least one question');
      return;
    }

    // Validate all questions
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      if (q.question.isEmpty) {
        Get.snackbar('Error', 'Question ${i + 1} is empty');
        return;
      }
      if (q.options.any((opt) => opt.isEmpty)) {
        Get.snackbar('Error', 'All options for question ${i + 1} must be filled');
        return;
      }
    }

    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create content first
      final content = ContentModel(
        id: '',
        courseId: courseId!,
        title: titleController.text,
        description: descriptionController.text,
        contentType: 'mcq',
        url: '', // Not used for MCQ
        order: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final contentId = await _contentRepo.createContent(content);

      // Create MCQ
      final mcq = MCQModel(
        id: '',
        contentId: contentId,
        courseId: courseId!,
        title: titleController.text,
        description: descriptionController.text,
        questions: questions.toList(),
        timeLimit: int.tryParse(timeLimitController.text) ?? 30,
        passingScore: int.tryParse(passingScoreController.text) ?? 70,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _mcqRepo.createMCQ(mcq);

      // Update course stats
      await _updateCourseStats();

      Get.back(); // Close loading
      Get.back(); // Go back to content list

      Get.snackbar(
        'Success',
        'MCQ Quiz created successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      print('Error saving MCQ: $e');
      Get.snackbar('Error', 'Failed to create quiz: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateCourseStats() async {
    try {
      final contents = await _contentRepo.getContentByCourse(courseId!);
      final mcqCount = contents.where((c) => c.contentType == 'mcq').length;

      await _courseRepo.updateCourse(courseId!, {
        'totalContent': contents.length,
        'totalMCQs': mcqCount,
      });
    } catch (e) {
      print('Error updating course stats: $e');
    }
  }
}
