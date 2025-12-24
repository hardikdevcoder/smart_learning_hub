import 'package:get/get.dart';

import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_pages.dart';

class AdminDashboardController extends GetxController {
  final _courseRepo = Get.find<CourseRepository>();
  final _userRepo = Get.find<UserRepository>();

  // Observables
  final isLoading = false.obs;
  final totalCourses = 0.obs;
  final totalStudents = 0.obs;
  final totalContent = 0.obs;
  final activeToday = 0.obs;
  final recentCourses = <CourseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Load all courses
      final courses = await _courseRepo.getAllCourses();
      recentCourses.value = courses.take(5).toList();
      totalCourses.value = courses.length;

      // Calculate total content
      int contentCount = 0;
      for (var course in courses) {
        contentCount += course.totalContent;
      }
      totalContent.value = contentCount;

      // Load students
      final students = await _userRepo.getAllStudents();
      totalStudents.value = students.length;

      // Mock active today (in production, query by lastLogin date)
      activeToday.value = (students.length * 0.3).round();
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Don't show error on first load, just log it
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  void createNewCourse() {
    Get.toNamed(Routes.ADMIN_COURSES, arguments: {'action': 'create'});
  }

  void editCourse(String courseId) {
    Get.toNamed(
      Routes.ADMIN_COURSES,
      arguments: {'action': 'edit', 'courseId': courseId},
    );
  }
}
