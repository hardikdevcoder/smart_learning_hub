import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import 'admin_users_controller.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Obx(() => _buildFilterChips()),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredUsers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadUsers,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredUsers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = controller.filteredUsers[index];
              return _buildUserCard(user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Students', 'student'),
          const SizedBox(width: 8),
          _buildFilterChip('Admins', 'admin'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => controller.changeFilter(value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildUserCard(user) {
    return Card(
      child: InkWell(
        onTap: () => controller.viewUserDetails(user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person, size: 30) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Get.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Get.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.isAdmin ? AppColors.adminPrimary.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: user.isAdmin ? AppColors.adminPrimary : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'role') {
                    controller.changeUserRole(user.uid, user.role);
                  } else if (value == 'details') {
                    controller.viewUserDetails(user);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 12),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz),
                        const SizedBox(width: 12),
                        Text('Change to ${user.isAdmin ? "Student" : "Admin"}'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'No Users Found',
              style: Get.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Users will appear here once they sign up',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
