import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/services/firebase_service.dart';
import '../../core/values/app_constants.dart';
import '../models/user_model.dart';

class UserRepository extends GetxService {
  final _firestore = FirebaseService.to.firestore;

  CollectionReference get _usersCollection => _firestore.collection(AppConstants.usersCollection);

  // Create User
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Get User by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Update User
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Delete User
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Get All Students (Admin)
  Future<List<UserModel>> getAllStudents() async {
    try {
      final snapshot = await _usersCollection.where('role', isEqualTo: 'student').orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting students: $e');
      rethrow;
    }
  }

  // Update User Role (Admin only)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _usersCollection.doc(uid).update({'role': role});
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  // Stream User
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
}
