import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/user_model.dart';
import '../values/app_constants.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late GetStorage _box;

  // static Future<StorageService> mainInit() async {
  //   // await GetStorage.init();
  //   return StorageService();
  // }

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage(AppConstants.storageKey);
    print('✅ Storage service initialized');
    return this;
    await GetStorage.init(AppConstants.storageKey);
  }

  // User Management
  Future<void> saveUser(UserModel user) async {
    await _box.write(AppConstants.userKey, jsonEncode(user.toLocalJson()));
  }

  UserModel? getUser() {
    final userJson = _box.read(AppConstants.userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  Future<void> removeUser() async {
    await _box.remove(AppConstants.userKey);
  }

  // Generic Storage Methods
  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> clearAll() async {
    await _box.erase();
  }

  bool hasData(String key) {
    return _box.hasData(key);
  }

  // Theme Management
  Future<void> saveThemeMode(String mode) async {
    await write(AppConstants.themeKey, mode);
  }

  String getThemeMode() {
    return read<String>(AppConstants.themeKey) ?? 'light';
  }

  // Language Management
  Future<void> saveLanguage(String language) async {
    await write(AppConstants.languageKey, language);
  }

  String getLanguage() {
    return read<String>(AppConstants.languageKey) ?? 'en';
  }
}

// import 'dart:convert';
//
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../data/models/user_model.dart';
// import '../values/app_constants.dart';
//
// class StorageService extends GetxService {
//   static StorageService get to => Get.find();
//
//   late SharedPreferences _prefs;
//
//   Future<StorageService> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     print('✅ Storage service initialized');
//     return this;
//   }
//
//   // User Management
//   Future<void> saveUser(UserModel user) async {
//     await _prefs.setString(
//       AppConstants.userKey,
//       jsonEncode(user.toLocalJson()),
//     );
//   }
//
//   UserModel? getUser() {
//     final userJson = _prefs.getString(AppConstants.userKey);
//     if (userJson == null) return null;
//     return UserModel.fromJson(jsonDecode(userJson));
//   }
//
//   Future<void> removeUser() async {
//     await _prefs.remove(AppConstants.userKey);
//   }
//
//   // Generic Storage Methods
//   T? read<T>(String key) {
//     final value = _prefs.get(key);
//     return value as T?;
//   }
//
//   Future<void> write(String key, dynamic value) async {
//     if (value is String) {
//       await _prefs.setString(key, value);
//     } else if (value is int) {
//       await _prefs.setInt(key, value);
//     } else if (value is double) {
//       await _prefs.setDouble(key, value);
//     } else if (value is bool) {
//       await _prefs.setBool(key, value);
//     } else if (value is List<String>) {
//       await _prefs.setStringList(key, value);
//     } else {
//       // For complex objects, store as JSON string
//       await _prefs.setString(key, jsonEncode(value));
//     }
//   }
//
//   Future<void> remove(String key) async {
//     await _prefs.remove(key);
//   }
//
//   Future<void> clearAll() async {
//     await _prefs.clear();
//   }
//
//   bool hasData(String key) {
//     return _prefs.containsKey(key);
//   }
//
//   // Theme Management
//   Future<void> saveThemeMode(String mode) async {
//     await _prefs.setString(AppConstants.themeKey, mode);
//   }
//
//   String getThemeMode() {
//     return _prefs.getString(AppConstants.themeKey) ?? 'light';
//   }
//
//   // Language Management
//   Future<void> saveLanguage(String language) async {
//     await _prefs.setString(AppConstants.languageKey, language);
//   }
//
//   String getLanguage() {
//     return _prefs.getString(AppConstants.languageKey) ?? 'en';
//   }
// }
//
// // import 'dart:convert';
// //
// // import 'package:get/get.dart';
// // import 'package:hive_flutter/hive_flutter.dart';
// //
// // import '../../data/models/user_model.dart';
// // import '../values/app_constants.dart';
// //
// // class StorageService extends GetxService {
// //   static StorageService get to => Get.find();
// //
// //   late Box _box;
// //
// //   Future<StorageService> init() async {
// //     await Hive.initFlutter();
// //     _box = await Hive.openBox(AppConstants.storageKey);
// //     print('✅ Storage service initialized');
// //     return this;
// //   }
// //
// //   // User Management
// //   Future<void> saveUser(UserModel user) async {
// //     await _box.put(AppConstants.userKey, jsonEncode(user.toLocalJson()));
// //   }
// //
// //   UserModel? getUser() {
// //     final userJson = _box.get(AppConstants.userKey);
// //     if (userJson == null) return null;
// //     return UserModel.fromJson(jsonDecode(userJson));
// //   }
// //
// //   Future<void> removeUser() async {
// //     await _box.delete(AppConstants.userKey);
// //   }
// //
// //   // Generic Storage Methods
// //   T? read<T>(String key) {
// //     return _box.get(key) as T?;
// //   }
// //
// //   Future<void> write(String key, dynamic value) async {
// //     await _box.put(key, value);
// //   }
// //
// //   Future<void> remove(String key) async {
// //     await _box.delete(key);
// //   }
// //
// //   Future<void> clearAll() async {
// //     await _box.clear();
// //   }
// //
// //   bool hasData(String key) {
// //     return _box.containsKey(key);
// //   }
// //
// //   // Theme Management
// //   Future<void> saveThemeMode(String mode) async {
// //     await _box.put(AppConstants.themeKey, mode);
// //   }
// //
// //   String getThemeMode() {
// //     return _box.get(AppConstants.themeKey, defaultValue: 'light') ?? 'light';
// //   }
// //
// //   // Language Management
// //   Future<void> saveLanguage(String language) async {
// //     await _box.put(AppConstants.languageKey, language);
// //   }
// //
// //   String getLanguage() {
// //     return _box.get(AppConstants.languageKey, defaultValue: 'en') ?? 'en';
// //   }
// // }
