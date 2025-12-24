import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../routes/app_pages.dart';

class AuthController extends GetxController {
  final authService = Get.find<AuthService>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null) {
        // Wait for auth service to load user data
        await Future.delayed(const Duration(milliseconds: 500));

        if (authService.isAdmin) {
          Get.offAllNamed(Routes.ADMIN_DASHBOARD);
        } else {
          Get.offAllNamed(Routes.STUDENT_DASHBOARD);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to sign in. Please try again.';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
