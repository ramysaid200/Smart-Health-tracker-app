import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../services/date_service.dart';

/// Water intake state provider
class WaterProvider extends ChangeNotifier {
  WaterProvider(this._uid);

  final String _uid;
  final _fs = FirebaseService.instance;
  final _storage = StorageService.instance;
  final _dates = DateService.instance;

  WaterLogModel? _today;
  List<Map<String, dynamic>> _weekData = [];
  bool _isLoading = false;
  String? _error;

  int get glasses => _today?.glasses ?? 0;
  int get goal => _storage.dailyWaterGoal;
  List<Map<String, dynamic>> get logs => _today?.logs ?? [];
  List<Map<String, dynamic>> get weekData => _weekData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadToday() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todayKey = _dates.todayKey();
      final doc = await _fs.getDocument(_fs.subPath(_uid, 'water', todayKey));
      if (doc.exists && doc.data() != null) {
        _today = WaterLogModel.fromFirestore(doc.data()!);
      } else {
        _today = WaterLogModel(date: todayKey, glasses: 0, goal: goal);
      }
      await _loadWeekData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load water data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWater(int ml) async {
    final glasses250 = (ml / 250).ceil(); // convert ml to glasses
    final todayKey = _dates.todayKey();
    final current = _today ?? WaterLogModel(date: todayKey, glasses: 0, goal: goal);
    final newLog = {'amount': ml, 'time': DateFormat('h:mm a').format(DateTime.now())};

    _today = WaterLogModel(
      date: todayKey,
      glasses: current.glasses + glasses250,
      goal: current.goal,
      logs: [...current.logs, newLog],
    );
    notifyListeners();

    await _fs.setDocument(_fs.subPath(_uid, 'water', todayKey), _today!.toMap());
  }

  Future<void> _loadWeekData() async {
    final keys = _dates.last7DayKeys();
    final results = await Future.wait(keys.map((k) => _fs.getDocument(_fs.subPath(_uid, 'water', k))));
    _weekData = results.asMap().entries.map((e) {
      final doc = e.value;
      final glasses = doc.exists && doc.data() != null
          ? (doc.data()!['glasses'] as num?)?.toInt() ?? 0
          : 0;
      return {'label': _dates.shortLabelForKey(keys[e.key]).substring(0, 2), 'glasses': glasses};
    }).toList();
  }
}
