import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import 'auth_repository.dart';

/// Firebase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  Stream<User?> get authStateStream => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Login failed. Please try again.';
    }
  }

  @override
  Future<String?> register(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());

      // Create Firestore document
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );
      await _db.doc('users/${user.uid}').set(userModel.toMap());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Registration failed. Please try again.';
    }
  }

  @override
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (_) {
      return 'Failed to send reset email.';
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _db.doc('users/${user.uid}').get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, user.uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> updateUserProfile(UserModel user) async {
    try {
      await _db.doc('users/${user.uid}').set(user.toMap(), SetOptions(merge: true));
      return null;
    } catch (e) {
      return 'Failed to update profile.';
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
