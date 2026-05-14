import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../../services/storage_service.dart';

/// Auth state manager using ChangeNotifier (Provider)
class AuthProvider extends ChangeNotifier {
  AuthProvider() : _repository = AuthRepositoryImpl() {
    _listenToAuthState();
  }

  final AuthRepository _repository;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _initialized;
  User? get firebaseUser => _repository.currentUser;

  void _listenToAuthState() {
    _repository.authStateStream.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _repository.getCurrentUserModel();
        if (_user != null) {
          await StorageService.instance.setUserId(firebaseUser.uid);
          await StorageService.instance.setUserName(_user!.name);
        }
      } else {
        _user = null;
      }
      _initialized = true;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final error = await _repository.login(email, password);
    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }

    // User will be set by auth state listener
    _setLoading(false);
    return true;
  }

  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    final error = await _repository.register(email, password, name);
    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    final error = await _repository.sendPasswordReset(email);
    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<void> logout() async {
    await _repository.logout();
    await StorageService.instance.clearUserData();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(UserModel updated) async {
    _setLoading(true);
    final error = await _repository.updateUserProfile(updated);
    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }
    _user = updated;
    _setLoading(false);
    return true;
  }

  void clearError() => _clearError();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
