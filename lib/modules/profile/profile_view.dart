import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/values/app_colors.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: controller.showSettings,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildLearningProgress(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildAccountSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: controller.photoUrl != null ? NetworkImage(controller.photoUrl!) : null,
                    child: controller.photoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: controller.editProfile,
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              controller.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            // Email
            Text(
              controller.email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.isAdmin ? Icons.admin_panel_settings : Icons.school,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.isAdmin ? 'Admin' : 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Member Since
            Obx(() => Text(
                  'Member for ${controller.memberSince}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.school_rounded,
              title: 'Total Courses',
              value: controller.totalCourses.toString(),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Completed',
                  value: controller.completedCourses.value.toString(),
                  color: AppColors.success,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
                  icon: Icons.timer_rounded,
                  title: 'Learning Time',
                  value: controller.learningTimeFormatted,
                  color: AppColors.warning,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Get.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Learning Progress',
                  style: Get.textTheme.titleLarge,
                ),
                Obx(() => Text(
                      '${controller.averageProgress}%',
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => LinearProgressIndicator(
                  value: controller.averageProgress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                )),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildProgressItem(
                        'In Progress',
                        controller.inProgressCourses.value.toString(),
                        AppColors.warning,
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _buildProgressItem(
                        'Completed',
                        controller.completedCourses.value.toString(),
                        AppColors.success,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Get.textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: controller.editProfile,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.history_rounded,
            title: 'Learning History',
            subtitle: 'View your progress timeline',
            onTap: () => Get.snackbar('Coming Soon', 'Feature in development'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.bookmark_outline,
            title: 'Saved Courses',
            subtitle: 'Your bookmarked courses',
            onTap: () => Get.snackbar('Coming Soon', 'Feature in development'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Account',
              style: Get.textTheme.titleLarge,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.warning),
                  title: const Text('Logout'),
                  subtitle: const Text('Sign out of your account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: controller.logout,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: AppColors.error),
                  ),
                  subtitle: const Text('Permanently delete your account'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.error),
                  onTap: controller.deleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
