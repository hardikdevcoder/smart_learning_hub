import 'package:get/get.dart';

import 'course_learning_controller.dart';

class CourseLearningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseLearningController>(() => CourseLearningController());
  }
}
