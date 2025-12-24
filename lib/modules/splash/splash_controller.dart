import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();

    // debugPrint("onInit called");

    print("hello!!!");
    print("hello!!! 222");
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    print('authService.... ${authService.isAuthenticated}');
    await Future.delayed(const Duration(seconds: 2));

    print('authService.isAuthenticated ${authService.isAuthenticated}');
    if (authService.isAuthenticated) {
      print('authService.isAdmin ${authService.isAdmin}');
      if (authService.isAdmin) {
        Get.offAllNamed(Routes.ADMIN_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.STUDENT_DASHBOARD);
      }
    } else {
      Get.offAllNamed(Routes.AUTH);
    }
  }

  navigateToNextScreen() {
    // await Future.delayed(const Duration(seconds: 2));

    print('authService.isAuthenticated ${authService.isAuthenticated}');
    if (authService.isAuthenticated) {
      print('authService.isAdmin ${authService.isAdmin}');
      if (authService.isAdmin) {
        Get.offAllNamed(Routes.ADMIN_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.STUDENT_DASHBOARD);
      }
    } else {
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
