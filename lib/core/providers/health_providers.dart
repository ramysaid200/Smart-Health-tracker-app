import 'package:flutter/foundation.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../services/date_service.dart';

/// Steps tracking state provider
class StepsProvider extends ChangeNotifier {
  StepsProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;
  final _storage = StorageService.instance;
  final _dates = DateService.instance;

  StepsLogModel? _today;
  List<Map<String, dynamic>> _weekData = [];
  bool _isLoading = false;
  String? _error;

  int get steps => _today?.count ?? 0;
  int get goal => _storage.dailyStepsGoal;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get weekData => _weekData;

  Future<void> loadToday() async {
    _isLoading = true; notifyListeners();
    try {
      final todayKey = _dates.todayKey();
      final doc = await _fs.getDocument(_fs.subPath(_uid, 'steps', todayKey));
      _today = doc.exists && doc.data() != null
          ? StepsLogModel.fromFirestore(doc.data()!)
          : StepsLogModel(date: todayKey, count: 0, goal: goal);
      await _loadWeekData();
      _error = null;
    } catch (_) { _error = 'Failed to load steps'; }
    _isLoading = false; notifyListeners();
  }

  Future<void> logSteps(int count) async {
    final todayKey = _dates.todayKey();
    _today = StepsLogModel(date: todayKey, count: count, goal: goal);
    notifyListeners();
    await _fs.setDocument(_fs.subPath(_uid, 'steps', todayKey), _today!.toMap());
  }

  Future<void> _loadWeekData() async {
    final keys = _dates.last7DayKeys();
    final results = await Future.wait(keys.map((k) => _fs.getDocument(_fs.subPath(_uid, 'steps', k))));
    _weekData = results.asMap().entries.map((e) {
      final doc = e.value;
      final count = doc.exists && doc.data() != null ? (doc.data()!['count'] as num?)?.toInt() ?? 0 : 0;
      return {'label': _dates.shortLabelForKey(keys[e.key]).substring(0, 2), 'steps': count};
    }).toList();
  }
}

/// Nutrition state provider
class NutritionProvider extends ChangeNotifier {
  NutritionProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;
  final _storage = StorageService.instance;
  final _dates = DateService.instance;

  NutritionLogModel? _today;
  bool _isLoading = false;
  String? _error;

  NutritionLogModel? get today => _today;
  int get calorieGoal => _storage.dailyCalorieGoal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadToday() async {
    _isLoading = true; notifyListeners();
    try {
      final todayKey = _dates.todayKey();
      final doc = await _fs.getDocument(_fs.subPath(_uid, 'nutrition', todayKey));
      _today = doc.exists && doc.data() != null
          ? NutritionLogModel.fromFirestore(doc.data()!)
          : NutritionLogModel(date: todayKey, calorieGoal: calorieGoal);
      _error = null;
    } catch (_) { _error = 'Failed to load nutrition'; }
    _isLoading = false; notifyListeners();
  }

  Future<void> addFoodItem(FoodItemModel item, String mealType) async {
    final todayKey = _dates.todayKey();
    final current = _today ?? NutritionLogModel(date: todayKey, calorieGoal: calorieGoal);
    List<FoodItemModel> breakfast = List.from(current.breakfast);
    List<FoodItemModel> lunch = List.from(current.lunch);
    List<FoodItemModel> dinner = List.from(current.dinner);
    List<FoodItemModel> snacks = List.from(current.snacks);
    switch (mealType) {
      case 'breakfast': breakfast.add(item); break;
      case 'lunch': lunch.add(item); break;
      case 'dinner': dinner.add(item); break;
      default: snacks.add(item);
    }
    _today = NutritionLogModel(
      date: todayKey, breakfast: breakfast, lunch: lunch,
      dinner: dinner, snacks: snacks, calorieGoal: calorieGoal,
    );
    notifyListeners();
    await _fs.setDocument(_fs.subPath(_uid, 'nutrition', todayKey), _today!.toMap());
  }
}

/// Sleep state provider
class SleepProvider extends ChangeNotifier {
  SleepProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;
  final _dates = DateService.instance;

  SleepLogModel? _latest;
  List<SleepLogModel> _weekLogs = [];
  bool _isLoading = false;

  SleepLogModel? get latest => _latest;
  List<SleepLogModel> get weekLogs => _weekLogs;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final query = await _fs.getCollection(_fs.collectionPath(_uid, 'sleep'), orderBy: 'date', descending: true, limit: 7);
      _weekLogs = query.docs.map((d) => SleepLogModel.fromFirestore(d.data())).toList();
      _latest = _weekLogs.isNotEmpty ? _weekLogs.first : null;
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<void> addSleep(SleepLogModel log) async {
    await _fs.setDocument(_fs.subPath(_uid, 'sleep', log.date), log.toMap());
    _latest = log;
    _weekLogs = [log, ..._weekLogs.take(6)];
    notifyListeners();
  }
}

/// Weight state provider
class WeightProvider extends ChangeNotifier {
  WeightProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;

  List<WeightLogModel> _logs = [];
  bool _isLoading = false;

  List<WeightLogModel> get logs => _logs;
  WeightLogModel? get latest => _logs.isNotEmpty ? _logs.last : null;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final q = await _fs.getCollection(_fs.collectionPath(_uid, 'weight'), orderBy: 'date', descending: false, limit: 30);
      _logs = q.docs.map((d) => WeightLogModel.fromFirestore(d.data(), d.id)).toList();
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<void> addWeight(double weight, String unit) async {
    final doc = await _fs.addDocument(_fs.collectionPath(_uid, 'weight'), WeightLogModel(id: '', date: DateTime.now(), weight: weight, unit: unit).toMap());
    _logs.add(WeightLogModel(id: doc.id, date: DateTime.now(), weight: weight, unit: unit));
    notifyListeners();
  }
}

/// Vitals state provider
class VitalsProvider extends ChangeNotifier {
  VitalsProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;

  List<VitalsLogModel> _logs = [];
  bool _isLoading = false;

  List<VitalsLogModel> get logs => _logs;
  VitalsLogModel? get latest => _logs.isNotEmpty ? _logs.last : null;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final q = await _fs.getCollection(_fs.collectionPath(_uid, 'vitals'), orderBy: 'date', descending: true, limit: 20);
      _logs = q.docs.map((d) => VitalsLogModel.fromFirestore(d.data(), d.id)).toList();
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<void> addVitals(VitalsLogModel vitals) async {
    final doc = await _fs.addDocument(_fs.collectionPath(_uid, 'vitals'), vitals.toMap());
    _logs.insert(0, VitalsLogModel(id: doc.id, date: vitals.date, heartRate: vitals.heartRate, systolic: vitals.systolic, diastolic: vitals.diastolic, notes: vitals.notes));
    notifyListeners();
  }
}

/// Medications state provider
class MedicationProvider extends ChangeNotifier {
  MedicationProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;

  List<MedicationModel> _medications = [];
  bool _isLoading = false;

  List<MedicationModel> get medications => _medications;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final q = await _fs.getCollection(_fs.collectionPath(_uid, 'medications'));
      _medications = q.docs.map((d) => MedicationModel.fromFirestore(d.data(), d.id)).toList();
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<void> addMedication(MedicationModel med) async {
    final doc = await _fs.addDocument(_fs.collectionPath(_uid, 'medications'), med.toMap());
    _medications.add(MedicationModel(
      id: doc.id, name: med.name, dosage: med.dosage, frequency: med.frequency,
      times: med.times, startDate: med.startDate, reminderEnabled: med.reminderEnabled,
    ));
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    await _fs.deleteDocument(_fs.subPath(_uid, 'medications', id));
    _medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}

/// Workout state provider
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;

  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final q = await _fs.getCollection(_fs.collectionPath(_uid, 'workouts'), orderBy: 'date', descending: true, limit: 20);
      _workouts = q.docs.map((d) => WorkoutModel.fromFirestore(d.data(), d.id)).toList();
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    final doc = await _fs.addDocument(_fs.collectionPath(_uid, 'workouts'), workout.toMap());
    _workouts.insert(0, WorkoutModel(
      id: doc.id, date: workout.date, type: workout.type,
      durationMinutes: workout.durationMinutes, caloriesBurned: workout.caloriesBurned,
      intensity: workout.intensity, notes: workout.notes,
    ));
    notifyListeners();
  }

  Future<void> deleteWorkout(String id) async {
    await _fs.deleteDocument(_fs.subPath(_uid, 'workouts', id));
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }
}
