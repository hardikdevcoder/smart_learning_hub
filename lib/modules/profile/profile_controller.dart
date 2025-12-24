import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_constants.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _enrollmentRepo = Get.find<EnrollmentRepository>();

  final isLoading = false.obs;
  final enrollments = <EnrollmentModel>[].obs;
  final completedCourses = 0.obs;
  final inProgressCourses = 0.obs;
  final totalLearningTime = 0.obs; // in minutes

  UserModel? get user => _authService.user;
  String get displayName => user?.displayName ?? 'Student';
  String get email => user?.email ?? '';
  String? get photoUrl => user?.photoUrl;
  bool get isAdmin => user?.isAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      isLoading.value = true;

      if (user?.uid != null) {
        // Load enrollments
        final userEnrollments = await _enrollmentRepo.getUserEnrollments(user!.uid);
        enrollments.value = userEnrollments;

        // Calculate statistics
        completedCourses.value = userEnrollments.where((e) => e.isCompleted).length;
        inProgressCourses.value = userEnrollments.where((e) => !e.isCompleted).length;

        // Calculate total learning time (mock calculation)
        totalLearningTime.value = userEnrollments.length * 45; // ~45 min per course
      }
    } catch (e) {
      print('Error loading profile data: $e');
      Get.snackbar('Error', 'Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  int get totalCourses => enrollments.length;

  int get averageProgress {
    if (enrollments.isEmpty) return 0;
    final total = enrollments.fold<int>(0, (sum, e) => sum + e.progress);
    return (total / enrollments.length).round();
  }

  String get learningTimeFormatted {
    final hours = totalLearningTime.value ~/ 60;
    final minutes = totalLearningTime.value % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get memberSince {
    if (user?.createdAt == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(user!.createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
    return 'Today';
  }

  Future<void> refreshProfile() async {
    await loadProfileData();
  }

  void editProfile() {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text(
          'Profile editing feature coming soon!\n\nYou can currently update your profile through Google Account settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showSettings() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                _showComingSoon('Notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language'),
              subtitle: const Text('Change app language'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                _showComingSoon('Language Settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Theme'),
              subtitle: const Text('Light / Dark mode'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                _showComingSoon('Theme Settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.info),
              title: const Text('Help & Support'),
              onTap: () {
                Get.back();
                _showComingSoon('Help & Support');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.info),
              title: const Text('About'),
              onTap: () {
                Get.back();
                _showAboutDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available in the next update!',
      duration: const Duration(seconds: 2),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About ${AppConstants.appName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'A comprehensive Learning Management System built with Flutter and Firebase.',
            ),
            const SizedBox(height: 12),
            Text(
              '© 2025 ${AppConstants.appName}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              await _authService.signOut();
              Get.back(); // Close loading

              Get.offAllNamed(Routes.AUTH);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\nThis action cannot be undone. All your data including course progress will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _authService.deleteAccount();
      Get.back(); // Close loading

      Get.offAllNamed(Routes.AUTH);

      Get.snackbar(
        'Account Deleted',
        'Your account has been successfully deleted',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading
      print('Error deleting account: $e');
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
