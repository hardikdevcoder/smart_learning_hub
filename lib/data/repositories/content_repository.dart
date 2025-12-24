import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/services/firebase_service.dart';
import '../../core/values/app_constants.dart';
import '../models/content_model.dart';

class ContentRepository extends GetxService {
  final _firestore = FirebaseService.to.firestore;

  CollectionReference get _contentCollection => _firestore.collection(AppConstants.contentCollection);

  // Create Content
  Future<String> createContent(ContentModel content) async {
    try {
      final docRef = await _contentCollection.add(content.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating content: $e');
      rethrow;
    }
  }

  // Get Content by ID
  Future<ContentModel?> getContentById(String contentId) async {
    try {
      final doc = await _contentCollection.doc(contentId).get();
      if (!doc.exists) return null;
      return ContentModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting content: $e');
      rethrow;
    }
  }

  // Get All Content for a Course
  Future<List<ContentModel>> getContentByCourse(String courseId) async {
    try {
      final snapshot = await _contentCollection.where('courseId', isEqualTo: courseId).orderBy('order').get();

      return snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting course content: $e');
      rethrow;
    }
  }

  // Get Content by Type
  Future<List<ContentModel>> getContentByType(String courseId, String contentType) async {
    try {
      final snapshot = await _contentCollection.where('courseId', isEqualTo: courseId).where('contentType', isEqualTo: contentType).orderBy('order').get();

      return snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting content by type: $e');
      rethrow;
    }
  }

  // Update Content
  Future<void> updateContent(String contentId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _contentCollection.doc(contentId).update(data);
    } catch (e) {
      print('Error updating content: $e');
      rethrow;
    }
  }

  // Delete Content
  Future<void> deleteContent(String contentId) async {
    try {
      await _contentCollection.doc(contentId).delete();
    } catch (e) {
      print('Error deleting content: $e');
      rethrow;
    }
  }

  // Reorder Content
  Future<void> reorderContent(List<String> contentIds, List<int> newOrders) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < contentIds.length; i++) {
        final docRef = _contentCollection.doc(contentIds[i]);
        batch.update(docRef, {
          'order': newOrders[i],
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error reordering content: $e');
      rethrow;
    }
  }

  // Stream Content for a Course
  Stream<List<ContentModel>> streamCourseContent(String courseId) {
    return _contentCollection
        .where('courseId', isEqualTo: courseId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList());
  }

  // Get Content Count by Type
  Future<Map<String, int>> getContentCountByCourse(String courseId) async {
    try {
      final contents = await getContentByCourse(courseId);

      int videoCount = 0;
      int pdfCount = 0;
      int pptCount = 0;
      int mcqCount = 0;

      for (var content in contents) {
        switch (content.contentType) {
          case AppConstants.contentTypeVideo:
            videoCount++;
            break;
          case AppConstants.contentTypePDF:
            pdfCount++;
            break;
          case AppConstants.contentTypePPT:
            pptCount++;
            break;
          case AppConstants.contentTypeMCQ:
            mcqCount++;
            break;
        }
      }

      return {
        'total': contents.length,
        'videos': videoCount,
        'pdfs': pdfCount,
        'ppts': pptCount,
        'mcqs': mcqCount,
      };
    } catch (e) {
      print('Error getting content count: $e');
      return {
        'total': 0,
        'videos': 0,
        'pdfs': 0,
        'ppts': 0,
        'mcqs': 0,
      };
    }
  }
}
