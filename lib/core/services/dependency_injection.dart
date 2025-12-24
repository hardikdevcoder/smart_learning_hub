import 'package:get/get.dart';
import 'package:smart_learning_hub/data/repositories/mcq_repository.dart';

import '../../data/repositories/content_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize Storage first
    await Get.putAsync(() => StorageService().init());

    // Initialize Firebase
    await Get.putAsync(() => FirebaseService().init());

    // Initialize Repositories
    Get.lazyPut(() => UserRepository(), fenix: true);
    Get.lazyPut(() => CourseRepository(), fenix: true);
    Get.lazyPut(() => ContentRepository(), fenix: true);
    Get.lazyPut(() => EnrollmentRepository(), fenix: true);
    Get.lazyPut(() => MCQRepository(), fenix: true);

    // Initialize Services
    Get.put(AuthService(), permanent: true);

    print('✅ All dependencies initialized');
  }
}
