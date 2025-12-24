import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/services/firebase_service.dart';
import '../../core/values/app_constants.dart';
import '../models/mcq_model.dart';

class MCQRepository extends GetxService {
  final _firestore = FirebaseService.to.firestore;

  CollectionReference get _mcqCollection => _firestore.collection(AppConstants.mcqCollection);

  // Create MCQ Quiz
  Future<String> createMCQ(MCQModel mcq) async {
    try {
      print('📝 Creating MCQ: ${mcq.title}');
      final docRef = await _mcqCollection.add(mcq.toJson());
      print('✅ MCQ created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating MCQ: $e');
      rethrow;
    }
  }

  // Get MCQ by ID
  Future<MCQModel?> getMCQById(String mcqId) async {
    try {
      final doc = await _mcqCollection.doc(mcqId).get();
      if (!doc.exists) return null;
      return MCQModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting MCQ: $e');
      rethrow;
    }
  }

  // Get MCQ by Content ID
  Future<MCQModel?> getMCQByContentId(String contentId) async {
    try {
      final snapshot = await _mcqCollection.where('contentId', isEqualTo: contentId).limit(1).get();

      if (snapshot.docs.isEmpty) return null;
      return MCQModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('❌ Error getting MCQ by content: $e');
      rethrow;
    }
  }

  // Get All MCQs for Course
  Future<List<MCQModel>> getMCQsByCourse(String courseId) async {
    try {
      final snapshot = await _mcqCollection.where('courseId', isEqualTo: courseId).get();

      return snapshot.docs.map((doc) => MCQModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error getting course MCQs: $e');
      rethrow;
    }
  }

  // Update MCQ
  Future<void> updateMCQ(String mcqId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _mcqCollection.doc(mcqId).update(data);
      print('✅ MCQ updated');
    } catch (e) {
      print('❌ Error updating MCQ: $e');
      rethrow;
    }
  }

  // Delete MCQ
  Future<void> deleteMCQ(String mcqId) async {
    try {
      await _mcqCollection.doc(mcqId).delete();
      print('✅ MCQ deleted');
    } catch (e) {
      print('❌ Error deleting MCQ: $e');
      rethrow;
    }
  }
}
