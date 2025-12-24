import 'package:get/get.dart';

import 'student_mcq_controller.dart';

class StudentMCQBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentMCQController>(() => StudentMCQController());
  }
}
