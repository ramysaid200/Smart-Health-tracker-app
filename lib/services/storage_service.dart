import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper for quick local caching
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Keys
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUseMetric = 'use_metric';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDailyCalorieGoal = 'daily_calorie_goal';
  static const String _keyDailyStepsGoal = 'daily_steps_goal';
  static const String _keyDailyWaterGoal = 'daily_water_goal';
  static const String _keyLastSyncDate = 'last_sync_date';
  static const String _keyActivityLevel = 'activity_level';
  static const String _keyUserWeight = 'user_weight';
  static const String _keyUserHeight = 'user_height';

  // ──────────────────────────────────────────────────────────────────────────
  // Getters / Setters
  // ──────────────────────────────────────────────────────────────────────────

  bool get isOnboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool v) => _prefs.setBool(_keyOnboardingDone, v);

  String? get userId => _prefs.getString(_keyUserId);
  Future<void> setUserId(String? id) async {
    if (id == null) {
      await _prefs.remove(_keyUserId);
    } else {
      await _prefs.setString(_keyUserId, id);
    }
  }

  String? get userName => _prefs.getString(_keyUserName);
  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  bool get useMetric => _prefs.getBool(_keyUseMetric) ?? true;
  Future<void> setUseMetric(bool v) => _prefs.setBool(_keyUseMetric, v);

  bool get notificationsEnabled => _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_keyNotificationsEnabled, v);

  int get dailyCalorieGoal => _prefs.getInt(_keyDailyCalorieGoal) ?? 2000;
  Future<void> setDailyCalorieGoal(int v) => _prefs.setInt(_keyDailyCalorieGoal, v);

  int get dailyStepsGoal => _prefs.getInt(_keyDailyStepsGoal) ?? 10000;
  Future<void> setDailyStepsGoal(int v) => _prefs.setInt(_keyDailyStepsGoal, v);

  int get dailyWaterGoal => _prefs.getInt(_keyDailyWaterGoal) ?? 8;
  Future<void> setDailyWaterGoal(int v) => _prefs.setInt(_keyDailyWaterGoal, v);

  String get activityLevel => _prefs.getString(_keyActivityLevel) ?? 'moderately_active';
  Future<void> setActivityLevel(String v) => _prefs.setString(_keyActivityLevel, v);

  double get userWeight => _prefs.getDouble(_keyUserWeight) ?? 70.0;
  Future<void> setUserWeight(double v) => _prefs.setDouble(_keyUserWeight, v);

  double get userHeight => _prefs.getDouble(_keyUserHeight) ?? 170.0;
  Future<void> setUserHeight(double v) => _prefs.setDouble(_keyUserHeight, v);

  String? get lastSyncDate => _prefs.getString(_keyLastSyncDate);
  Future<void> setLastSyncDate(String v) => _prefs.setString(_keyLastSyncDate, v);

  /// Clear all user data (on logout)
  Future<void> clearUserData() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyOnboardingDone);
    await _prefs.remove(_keyDailyCalorieGoal);
    await _prefs.remove(_keyDailyStepsGoal);
    await _prefs.remove(_keyDailyWaterGoal);
    await _prefs.remove(_keyActivityLevel);
    await _prefs.remove(_keyUserWeight);
    await _prefs.remove(_keyUserHeight);
    await _prefs.remove(_keyLastSyncDate);
  }
}
