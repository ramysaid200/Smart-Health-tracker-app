import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/health_models.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/date_service.dart';

/// Home dashboard provider – fetches today's summary from all metrics
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;
  final _storage = StorageService.instance;
  final _dates = DateService.instance;

  StepsLogModel? _steps;
  WaterLogModel? _water;
  NutritionLogModel? _nutrition;
  SleepLogModel? _sleep;
  WeightLogModel? _latestWeight;

  bool _isLoading = false;
  String? _error;

  StepsLogModel? get steps => _steps;
  WaterLogModel? get water => _water;
  NutritionLogModel? get nutrition => _nutrition;
  SleepLogModel? get sleep => _sleep;
  WeightLogModel? get latestWeight => _latestWeight;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get stepsGoal => _storage.dailyStepsGoal;
  int get waterGoal => _storage.dailyWaterGoal;
  int get calorieGoal => _storage.dailyCalorieGoal;

  int get currentSteps => _steps?.count ?? 0;
  int get currentWaterGlasses => _water?.glasses ?? 0;
  double get currentCalories => _nutrition?.totalCalories ?? 0;

  double get overallProgress {
    double total = 0;
    int count = 0;
    if (stepsGoal > 0) { total += currentSteps / stepsGoal; count++; }
    if (waterGoal > 0) { total += currentWaterGlasses / waterGoal; count++; }
    if (calorieGoal > 0) { total += (currentCalories / calorieGoal).clamp(0, 1); count++; }
    return count == 0 ? 0 : (total / count).clamp(0, 1);
  }

  Future<void> loadTodaySummary() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todayKey = _dates.todayKey();

      // Load in parallel
      final results = await Future.wait([
        _fs.getDocument(_fs.subPath(_uid, 'steps', todayKey)),
        _fs.getDocument(_fs.subPath(_uid, 'water', todayKey)),
        _fs.getDocument(_fs.subPath(_uid, 'nutrition', todayKey)),
        _fs.getCollection(
          _fs.collectionPath(_uid, 'weight'),
          orderBy: 'date',
          descending: true,
          limit: 1,
        ),
        _fs.getCollection(
          _fs.collectionPath(_uid, 'sleep'),
          orderBy: 'date',
          descending: true,
          limit: 1,
        ),
      ]);

      final stepsDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      if (stepsDoc.exists && stepsDoc.data() != null) {
        _steps = StepsLogModel.fromFirestore(stepsDoc.data()!);
      } else {
        _steps = StepsLogModel(date: todayKey, count: 0, goal: _storage.dailyStepsGoal);
      }

      final waterDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;
      if (waterDoc.exists && waterDoc.data() != null) {
        _water = WaterLogModel.fromFirestore(waterDoc.data()!);
      } else {
        _water = WaterLogModel(date: todayKey, glasses: 0, goal: _storage.dailyWaterGoal);
      }

      final nutritionDoc = results[2] as DocumentSnapshot<Map<String, dynamic>>;
      if (nutritionDoc.exists && nutritionDoc.data() != null) {
        _nutrition = NutritionLogModel.fromFirestore(nutritionDoc.data()!);
      } else {
        _nutrition = NutritionLogModel(date: todayKey, calorieGoal: _storage.dailyCalorieGoal);
      }

      final weightQuery = results[3] as QuerySnapshot<Map<String, dynamic>>;
      if (weightQuery.docs.isNotEmpty) {
        final doc = weightQuery.docs.first;
        _latestWeight = WeightLogModel.fromFirestore(doc.data(), doc.id);
      }

      final sleepQuery = results[4] as QuerySnapshot<Map<String, dynamic>>;
      if (sleepQuery.docs.isNotEmpty) {
        _sleep = SleepLogModel.fromFirestore(sleepQuery.docs.first.data());
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load today\'s data';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Quick add water (+1 glass)
  Future<void> quickAddWater() async {
    final todayKey = _dates.todayKey();
    final current = _water ?? WaterLogModel(date: todayKey, glasses: 0, goal: _storage.dailyWaterGoal);
    final updated = WaterLogModel(
      date: todayKey,
      glasses: current.glasses + 1,
      goal: current.goal,
      logs: [
        ...current.logs,
        {'timestamp': DateTime.now().toIso8601String(), 'amount': 250},
      ],
    );
    _water = updated;
    notifyListeners();
    await _fs.setDocument(_fs.subPath(_uid, 'water', todayKey), updated.toMap());
  }

  void setError(String? e) { _error = e; notifyListeners(); }
}
