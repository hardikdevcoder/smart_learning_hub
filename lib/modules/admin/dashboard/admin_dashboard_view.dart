import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/values/app_colors.dart';
import '../../../routes/app_pages.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications_outlined),
          //   onPressed: () {},
          // ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Get.toNamed(Routes.PROFILE);
              } else if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(),
              const SizedBox(height: 24),

              // Stats Overview
              Text(
                'Overview',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Obx(() => _buildStatsGrid()),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Courses',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Obx(() => _buildRecentCourses()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final user = Get.find<AuthService>().user;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
            child: user?.photoUrl == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.displayName ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          icon: Icons.school_rounded,
          title: 'Total Courses',
          value: controller.totalCourses.value.toString(),
          color: AppColors.primary,
          onTap: () => Get.toNamed(Routes.ADMIN_COURSES),
        ),
        _buildStatCard(
          icon: Icons.people_rounded,
          title: 'Total Students',
          value: controller.totalStudents.value.toString(),
          color: AppColors.secondary,
          onTap: () => Get.toNamed(Routes.ADMIN_USERS),
        ),
        _buildStatCard(
          icon: Icons.video_library_rounded,
          title: 'Total Content',
          value: controller.totalContent.value.toString(),
          color: AppColors.videoColor,
        ),
        _buildStatCard(
          icon: Icons.trending_up_rounded,
          title: 'Active Today',
          value: controller.activeToday.value.toString(),
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Get.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _buildActionCard(
          icon: Icons.add_circle_outline,
          label: 'New Course',
          color: AppColors.primary,
          onTap: controller.createNewCourse,
        ),
        _buildActionCard(
          icon: Icons.people_outline,
          label: 'Users',
          color: AppColors.secondary,
          onTap: () => Get.toNamed(Routes.ADMIN_USERS),
        ),
        // _buildActionCard(
        //   icon: Icons.video_library_outlined,
        //   label: 'Content',
        //   color: AppColors.videoColor,
        //   onTap: () => Get.toNamed(Routes.ADMIN_CONTENT),
        // ),
        // _buildActionCard(
        //   icon: Icons.analytics_outlined,
        //   label: 'Analytics',
        //   color: AppColors.info,
        //   onTap: () {},
        // ),
        // _buildActionCard(
        //   icon: Icons.settings_outlined,
        //   label: 'Settings',
        //   color: AppColors.textSecondary,
        //   onTap: () {},
        // ),
        // _buildActionCard(
        //   icon: Icons.help_outline,
        //   label: 'Help',
        //   color: AppColors.warning,
        //   onTap: () {},
        // ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourses() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.recentCourses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.recentCourses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = controller.recentCourses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Get.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.totalContent} items • ${course.enrolledCount} students',
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => controller.editCourse(course.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No courses yet',
            style: Get.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first course to get started',
            style: Get.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.createNewCourse,
            icon: const Icon(Icons.add),
            label: const Text('Create Course'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
              await Get.find<AuthService>().signOut();
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
}
