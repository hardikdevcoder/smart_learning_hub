part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const STUDENT_DASHBOARD = _Paths.STUDENT_DASHBOARD;
  static const STUDENT_COURSE = _Paths.STUDENT_COURSE;
  static const PROFILE = _Paths.PROFILE;
  static const COURSE_DETAIL = _Paths.COURSE_DETAIL;
  static const CONTENT_VIEWER = _Paths.CONTENT_VIEWER;
  static const ADMIN_COURSES = _Paths.ADMIN_COURSES;
  static const ADMIN_USERS = _Paths.ADMIN_USERS;
  static const ADMIN_CONTENT = _Paths.ADMIN_CONTENT;
  static const ADMIN_MCQ_CREATE = _Paths.ADMIN_MCQ_CREATE;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const ADMIN_DASHBOARD = '/admin';
  static const STUDENT_DASHBOARD = '/student';
  static const STUDENT_COURSE = '/student/course/:courseId';
  static const PROFILE = '/profile';
  static const COURSE_DETAIL = '/course/:id';
  static const CONTENT_VIEWER = '/content/:id';
  static const ADMIN_COURSES = '/admin/courses';
  static const ADMIN_USERS = '/admin/users';
  static const ADMIN_CONTENT = '/admin/content/:courseId';
  static const ADMIN_MCQ_CREATE = '/admin/mcq/create/:courseId';
}
