import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _auth = FirebaseService.to.auth;
  final _googleSignIn = GoogleSignIn();
  final _userRepo = Get.find<UserRepository>();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  User? get firebaseUser => _firebaseUser.value;
  UserModel? get user => _user.value;
  bool get isAuthenticated => _firebaseUser.value != null;
  bool get isAdmin => _user.value?.isAdmin ?? false;
  bool get isStudent => _user.value?.isStudent ?? false;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _handleAuthChanged);
  }

  // Handle auth state changes
  Future<void> _handleAuthChanged(User? user) async {
    if (user != null) {
      try {
        final userModel = await _userRepo.getUserById(user.uid);
        _user.value = userModel;
        await StorageService.to.saveUser(userModel!);
      } catch (e) {
        print('Error loading user data: $e');
        _user.value = null;
      }
    } else {
      _user.value = null;
      await StorageService.to.removeUser();
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user in Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  // Create or update user in Firestore
  Future<void> _createOrUpdateUser(User firebaseUser) async {
    try {
      final existingUser = await _userRepo.getUserById(firebaseUser.uid);

      if (existingUser == null) {
        // Create new user
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Student',
          photoUrl: firebaseUser.photoURL,
          role: 'student', // Default role
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await _userRepo.createUser(newUser);
      } else {
        // Update last login
        await _userRepo.updateUser(firebaseUser.uid, {'lastLogin': DateTime.now()});
      }
    } catch (e) {
      print('Error creating/updating user: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user.value = null;
      await StorageService.to.removeUser();
    } catch (e) {
      print('Sign Out Error: $e');
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final uid = _firebaseUser.value?.uid;
      if (uid != null) {
        await _userRepo.deleteUser(uid);
        await _firebaseUser.value?.delete();
        await _googleSignIn.signOut();
        _user.value = null;
        await StorageService.to.removeUser();
      }
    } catch (e) {
      print('Delete Account Error: $e');
      rethrow;
    }
  }
}
