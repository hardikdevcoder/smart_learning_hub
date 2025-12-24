import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/app_constants.dart';
import 'auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
                child: const Icon(Icons.school_rounded, size: 50, color: AppColors.primary),
              ),

              const SizedBox(height: 30),

              // Title
              Text(
                'Welcome to',
                style: Get.textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appName,
                style: Get.textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Your gateway to free quality education.\nLearn, grow, and achieve your goals.',
                style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 80),

              // Features
              _buildFeatureItem(Icons.video_library_rounded, 'Video Lectures', 'Watch high-quality video content'),
              const SizedBox(height: 20),
              _buildFeatureItem(Icons.picture_as_pdf_rounded, 'Study Materials', 'Access PDFs and presentations'),
              const SizedBox(height: 20),
              _buildFeatureItem(Icons.quiz_rounded, 'Practice Tests', 'Test your knowledge with MCQs'),

              const SizedBox(height: 60),

              // Google Sign In Button
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value ? null : controller.signInWithGoogle,
                  icon: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Image.asset(
                          'assets/images/google_logo.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.white),
                        ),
                  label: Text(controller.isLoading.value ? 'Signing In...' : 'Continue with Google'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: AppColors.primary),
                ),
              ),

              const SizedBox(height: 24),

              // Terms
              Text('By continuing, you agree to our\nTerms of Service and Privacy Policy', style: Get.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Get.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: Get.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
