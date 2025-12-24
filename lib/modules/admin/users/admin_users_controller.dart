import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class AdminUsersController extends GetxController {
  final _userRepo = Get.find<UserRepository>();

  final isLoading = false.obs;
  final users = <UserModel>[].obs;
  final filteredUsers = <UserModel>[].obs;
  final selectedFilter = 'all'.obs; // all, student, admin

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final allUsers = await _userRepo.getAllStudents();
      users.value = allUsers;
      applyFilter();
    } catch (e) {
      print('Error loading users: $e');
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((u) => u.role == selectedFilter.value).toList();
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  Future<void> changeUserRole(String userId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'student' : 'admin';

    Get.dialog(
      AlertDialog(
        title: Text('Change Role to ${newRole.toUpperCase()}'),
        content: Text(
          'Are you sure you want to change this user\'s role to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performRoleChange(userId, newRole);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRoleChange(String userId, String newRole) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _userRepo.updateUserRole(userId, newRole);
      Get.back();

      Get.snackbar(
        'Success',
        'User role updated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await loadUsers();
    } catch (e) {
      Get.back();
      print('Error changing role: $e');
      Get.snackbar('Error', 'Failed to change user role');
    }
  }

  void viewUserDetails(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.photoUrl != null)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.photoUrl!),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', user.displayName),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', user.role.toUpperCase()),
              _buildDetailRow(
                'Joined',
                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              ),
              if (user.lastLogin != null)
                _buildDetailRow(
                  'Last Login',
                  '${user.lastLogin!.day}/${user.lastLogin!.month}/${user.lastLogin!.year}',
                ),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
