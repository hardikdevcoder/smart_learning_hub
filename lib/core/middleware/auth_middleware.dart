import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // If not authenticated, redirect to auth
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: Routes.AUTH);
    }

    // Role-based routing
    if (route?.startsWith('/admin') ?? false) {
      if (!authService.isAdmin) {
        // Not admin, redirect to student dashboard
        return const RouteSettings(name: Routes.STUDENT_DASHBOARD);
      }
    }

    return null;
  }
}
