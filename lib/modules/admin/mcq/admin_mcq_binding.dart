import 'package:get/get.dart';

import 'admin_mcq_controller.dart';

class AdminMCQBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMCQController>(() => AdminMCQController());
  }
}
