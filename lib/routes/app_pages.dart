import 'package:get/get.dart';
import 'package:smart_learning_hub/modules/admin/mcq/admin_mcq_binding.dart';
import 'package:smart_learning_hub/modules/admin/mcq/admin_mcq_view.dart';

import '../core/middleware/auth_middleware.dart';
import '../modules/admin/content/admin_content_binding.dart';
import '../modules/admin/content/admin_content_view.dart';
import '../modules/admin/courses/admin_courses_binding.dart';
import '../modules/admin/courses/admin_courses_view.dart';
import '../modules/admin/dashboard/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/admin_dashboard_view.dart';
import '../modules/admin/users/admin_users_binding.dart';
import '../modules/admin/users/admin_users_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/auth_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/student/course/course_learning_binding.dart';
import '../modules/student/course/course_learning_view.dart';
import '../modules/student/dashboard/student_dashboard_binding.dart';
import '../modules/student/dashboard/student_dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),

    //Admin
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_COURSES,
      page: () => const AdminCoursesView(),
      binding: AdminCoursesBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_USERS,
      page: () => const AdminUsersView(),
      binding: AdminUsersBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_CONTENT,
      page: () => const AdminContentView(),
      binding: AdminContentBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_MCQ_CREATE,
      page: () => const AdminMCQView(),
      binding: AdminMCQBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Student
    GetPage(
      name: _Paths.STUDENT_DASHBOARD,
      page: () => const StudentDashboardView(),
      binding: StudentDashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.STUDENT_COURSE,
      page: () => const CourseLearningView(),
      binding: CourseLearningBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
