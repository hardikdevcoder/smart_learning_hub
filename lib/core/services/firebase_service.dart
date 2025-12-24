import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../../firebase_options.dart';

class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  Future<FirebaseService> init() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Initialize services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // Configure Firestore settings
      _firestore.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

      print('✅ Firebase initialized successfully');
      return this;
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }

  // Auth Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
