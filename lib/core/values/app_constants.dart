class AppConstants {
  // App Info
  static const String appName = 'Smart Learning Hub';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKey = 'smart_learning_hub';
  // static const String storageBoxName = 'app_storage'; // Add this

  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String contentCollection = 'content';
  static const String progressCollection = 'progress';
  static const String mcqCollection = 'mcqs';

  // Content Types
  static const String contentTypeVideo = 'video';
  static const String contentTypePDF = 'pdf';
  static const String contentTypePPT = 'ppt';
  static const String contentTypeMCQ = 'mcq';

  // Pagination
  static const int pageSize = 20;
  static const int maxCacheSize = 100;

  // Free Course Sources (Example URLs)
  static const String freeVideoSource = 'https://www.youtube.com/';
  static const String freePDFSource = 'https://drive.google.com/';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 24);
}
