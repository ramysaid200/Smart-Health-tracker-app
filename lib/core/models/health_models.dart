import 'package:cloud_firestore/cloud_firestore.dart';

/// Daily steps log model
class StepsLogModel {
  const StepsLogModel({
    required this.date,
    required this.count,
    this.goal = 10000,
    this.logs = const [],
  });

  final String date;
  final int count;
  final int goal;
  final List<Map<String, dynamic>> logs;

  double get progress => count / goal;

  factory StepsLogModel.fromFirestore(Map<String, dynamic> data) {
    return StepsLogModel(
      date: data['date'] as String? ?? '',
      count: (data['count'] as num?)?.toInt() ?? 0,
      goal: (data['goal'] as num?)?.toInt() ?? 10000,
      logs: List<Map<String, dynamic>>.from(data['logs'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'count': count,
        'goal': goal,
        'logs': logs,
      };

  StepsLogModel copyWith({int? count, int? goal, List<Map<String, dynamic>>? logs}) =>
      StepsLogModel(date: date, count: count ?? this.count, goal: goal ?? this.goal, logs: logs ?? this.logs);
}

/// Water intake log model
class WaterLogModel {
  const WaterLogModel({
    required this.date,
    required this.glasses,
    this.goal = 8,
    this.logs = const [],
  });

  final String date;
  final int glasses;
  final int goal;
  final List<Map<String, dynamic>> logs;

  double get progress => glasses / goal;

  factory WaterLogModel.fromFirestore(Map<String, dynamic> data) {
    return WaterLogModel(
      date: data['date'] as String? ?? '',
      glasses: (data['glasses'] as num?)?.toInt() ?? 0,
      goal: (data['goal'] as num?)?.toInt() ?? 8,
      logs: List<Map<String, dynamic>>.from(data['logs'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'glasses': glasses,
        'goal': goal,
        'logs': logs,
      };
}

/// Food item model
class FoodItemModel {
  const FoodItemModel({
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.quantity = '1 serving',
  });

  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String quantity;

  factory FoodItemModel.fromMap(Map<String, dynamic> data) {
    return FoodItemModel(
      name: data['name'] as String? ?? '',
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
      fats: (data['fats'] as num?)?.toDouble() ?? 0,
      quantity: data['quantity'] as String? ?? '1 serving',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'quantity': quantity,
      };
}

/// Daily nutrition log
class NutritionLogModel {
  const NutritionLogModel({
    required this.date,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
    this.calorieGoal = 2000,
  });

  final String date;
  final List<FoodItemModel> breakfast;
  final List<FoodItemModel> lunch;
  final List<FoodItemModel> dinner;
  final List<FoodItemModel> snacks;
  final int calorieGoal;

  double get totalCalories => [...breakfast, ...lunch, ...dinner, ...snacks]
      .fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => [...breakfast, ...lunch, ...dinner, ...snacks]
      .fold(0, (sum, item) => sum + item.protein);
  double get totalCarbs => [...breakfast, ...lunch, ...dinner, ...snacks]
      .fold(0, (sum, item) => sum + item.carbs);
  double get totalFats => [...breakfast, ...lunch, ...dinner, ...snacks]
      .fold(0, (sum, item) => sum + item.fats);
  double get calorieProgress => totalCalories / calorieGoal;

  factory NutritionLogModel.fromFirestore(Map<String, dynamic> data) {
    List<FoodItemModel> parseList(dynamic raw) =>
        (raw as List? ?? []).map((e) => FoodItemModel.fromMap(e as Map<String, dynamic>)).toList();

    final meals = data['meals'] as Map<String, dynamic>? ?? {};
    return NutritionLogModel(
      date: data['date'] as String? ?? '',
      breakfast: parseList(meals['breakfast']),
      lunch: parseList(meals['lunch']),
      dinner: parseList(meals['dinner']),
      snacks: parseList(meals['snacks']),
      calorieGoal: (data['calorieGoal'] as num?)?.toInt() ?? 2000,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'calorieGoal': calorieGoal,
        'meals': {
          'breakfast': breakfast.map((e) => e.toMap()).toList(),
          'lunch': lunch.map((e) => e.toMap()).toList(),
          'dinner': dinner.map((e) => e.toMap()).toList(),
          'snacks': snacks.map((e) => e.toMap()).toList(),
        },
        'totals': {
          'calories': totalCalories,
          'protein': totalProtein,
          'carbs': totalCarbs,
          'fats': totalFats,
        },
      };
}

/// Workout log model
class WorkoutModel {
  const WorkoutModel({
    required this.id,
    required this.date,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.intensity,
    this.notes,
  });

  final String id;
  final DateTime date;
  final String type;
  final int durationMinutes;
  final double caloriesBurned;
  final String intensity;
  final String? notes;

  factory WorkoutModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkoutModel(
      id: id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] as String? ?? 'walking',
      durationMinutes: (data['duration'] as num?)?.toInt() ?? 0,
      caloriesBurned: (data['caloriesBurned'] as num?)?.toDouble() ?? 0,
      intensity: data['intensity'] as String? ?? 'moderate',
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'type': type,
        'duration': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'intensity': intensity,
        if (notes != null) 'notes': notes,
      };
}

/// Sleep log model
class SleepLogModel {
  const SleepLogModel({
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
    this.notes,
  });

  final String date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final String quality; // poor, fair, good, excellent
  final String? notes;

  double get durationHours {
    final diff = wakeTime.difference(bedtime);
    return diff.inMinutes / 60.0;
  }

  factory SleepLogModel.fromFirestore(Map<String, dynamic> data) {
    return SleepLogModel(
      date: data['date'] as String? ?? '',
      bedtime: (data['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeTime: (data['wakeTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quality: data['quality'] as String? ?? 'good',
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'bedtime': Timestamp.fromDate(bedtime),
        'wakeTime': Timestamp.fromDate(wakeTime),
        'duration': durationHours,
        'quality': quality,
        if (notes != null) 'notes': notes,
      };
}

/// Weight log model
class WeightLogModel {
  const WeightLogModel({
    required this.id,
    required this.date,
    required this.weight,
    this.unit = 'kg',
  });

  final String id;
  final DateTime date;
  final double weight;
  final String unit;

  factory WeightLogModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WeightLogModel(
      id: id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weight: (data['weight'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
    );
  }

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'weight': weight,
        'unit': unit,
      };
}

/// Vitals log model (heart rate + blood pressure)
class VitalsLogModel {
  const VitalsLogModel({
    required this.id,
    required this.date,
    this.heartRate,
    this.systolic,
    this.diastolic,
    this.notes,
  });

  final String id;
  final DateTime date;
  final int? heartRate;
  final int? systolic;
  final int? diastolic;
  final String? notes;

  factory VitalsLogModel.fromFirestore(Map<String, dynamic> data, String id) {
    return VitalsLogModel(
      id: id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      heartRate: (data['heartRate'] as num?)?.toInt(),
      systolic: (data['systolic'] as num?)?.toInt(),
      diastolic: (data['diastolic'] as num?)?.toInt(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        if (heartRate != null) 'heartRate': heartRate,
        if (systolic != null) 'systolic': systolic,
        if (diastolic != null) 'diastolic': diastolic,
        if (notes != null) 'notes': notes,
      };
}

/// Medication model
class MedicationModel {
  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.reminderEnabled = true,
    this.notes,
    this.logs = const [],
  });

  final String id;
  final String name;
  final String dosage;
  final String frequency; // daily, weekly, custom
  final List<String> times; // e.g. ["08:00", "20:00"]
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderEnabled;
  final String? notes;
  final List<Map<String, dynamic>> logs;

  factory MedicationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MedicationModel(
      id: id,
      name: data['name'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      frequency: data['frequency'] as String? ?? 'daily',
      times: List<String>.from(data['times'] as List? ?? []),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      reminderEnabled: data['reminderEnabled'] as bool? ?? true,
      notes: data['notes'] as String?,
      logs: List<Map<String, dynamic>>.from(data['logs'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'times': times,
        'startDate': Timestamp.fromDate(startDate),
        if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
        'reminderEnabled': reminderEnabled,
        if (notes != null) 'notes': notes,
        'logs': logs,
      };
}
