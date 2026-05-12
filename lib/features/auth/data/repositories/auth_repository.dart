import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

/// Abstract auth repository interface
abstract class AuthRepository {
  /// Login with email and password. Returns error string or null on success.
  Future<String?> login(String email, String password);

  /// Register new user. Returns error string or null on success.
  Future<String?> register(String email, String password, String name);

  /// Send password reset email. Returns error string or null on success.
  Future<String?> sendPasswordReset(String email);

  /// Logout current user.
  Future<void> logout();

  /// Stream of auth state changes.
  Stream<User?> get authStateStream;

  /// Get current Firebase user.
  User? get currentUser;

  /// Get current UserModel from Firestore.
  Future<UserModel?> getCurrentUserModel();

  /// Update user profile in Firestore.
  Future<String?> updateUserProfile(UserModel user);
}
