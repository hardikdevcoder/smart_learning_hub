import 'package:get/get.dart';

import 'admin_content_controller.dart';

class AdminContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminContentController>(() => AdminContentController());
  }
}
