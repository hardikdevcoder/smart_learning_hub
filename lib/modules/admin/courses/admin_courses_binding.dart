import 'package:get/get.dart';

import 'admin_courses_controller.dart';

class AdminCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminCoursesController>(() => AdminCoursesController());
  }
}
