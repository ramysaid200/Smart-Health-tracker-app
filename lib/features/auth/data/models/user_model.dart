import 'package:cloud_firestore/cloud_firestore.dart';

/// User data model for Firestore storage
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.photoUrl,
    this.profile,
  });

  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final String? photoUrl;
  final UserProfile? profile;

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: data['photoUrl'] as String?,
      profile: data['profile'] != null
          ? UserProfile.fromMap(data['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'createdAt': Timestamp.fromDate(createdAt),
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (profile != null) 'profile': profile!.toMap(),
      };

  UserModel copyWith({
    String? email,
    String? name,
    String? photoUrl,
    UserProfile? profile,
  }) =>
      UserModel(
        uid: uid,
        email: email ?? this.email,
        name: name ?? this.name,
        createdAt: createdAt,
        photoUrl: photoUrl ?? this.photoUrl,
        profile: profile ?? this.profile,
      );
}

/// Nested user profile/health data
class UserProfile {
  const UserProfile({
    this.age = 25,
    this.gender = 'prefer_not_to_say',
    this.heightCm = 170,
    this.heightUnit = 'cm',
    this.weightKg = 70,
    this.weightUnit = 'kg',
    this.activityLevel = 'moderately_active',
    this.goals = const [],
    this.targetWeight,
    this.dailyCalorieGoal = 2000,
    this.dailyStepsGoal = 10000,
    this.dailyWaterGoal = 8,
  });

  final int age;
  final String gender;
  final double heightCm;
  final String heightUnit;
  final double weightKg;
  final String weightUnit;
  final String activityLevel;
  final List<String> goals;
  final double? targetWeight;
  final int dailyCalorieGoal;
  final int dailyStepsGoal;
  final int dailyWaterGoal;

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      age: (data['age'] as num?)?.toInt() ?? 25,
      gender: data['gender'] as String? ?? 'prefer_not_to_say',
      heightCm: (data['height'] as num?)?.toDouble() ?? 170,
      heightUnit: data['heightUnit'] as String? ?? 'cm',
      weightKg: (data['weight'] as num?)?.toDouble() ?? 70,
      weightUnit: data['weightUnit'] as String? ?? 'kg',
      activityLevel: data['activityLevel'] as String? ?? 'moderately_active',
      goals: List<String>.from(data['goals'] as List? ?? []),
      targetWeight: (data['targetWeight'] as num?)?.toDouble(),
      dailyCalorieGoal: (data['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
      dailyStepsGoal: (data['dailyStepsGoal'] as num?)?.toInt() ?? 10000,
      dailyWaterGoal: (data['dailyWaterGoal'] as num?)?.toInt() ?? 8,
    );
  }

  Map<String, dynamic> toMap() => {
        'age': age,
        'gender': gender,
        'height': heightCm,
        'heightUnit': heightUnit,
        'weight': weightKg,
        'weightUnit': weightUnit,
        'activityLevel': activityLevel,
        'goals': goals,
        if (targetWeight != null) 'targetWeight': targetWeight,
        'dailyCalorieGoal': dailyCalorieGoal,
        'dailyStepsGoal': dailyStepsGoal,
        'dailyWaterGoal': dailyWaterGoal,
      };

  UserProfile copyWith({
    int? age,
    String? gender,
    double? heightCm,
    String? heightUnit,
    double? weightKg,
    String? weightUnit,
    String? activityLevel,
    List<String>? goals,
    double? targetWeight,
    int? dailyCalorieGoal,
    int? dailyStepsGoal,
    int? dailyWaterGoal,
  }) =>
      UserProfile(
        age: age ?? this.age,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        heightUnit: heightUnit ?? this.heightUnit,
        weightKg: weightKg ?? this.weightKg,
        weightUnit: weightUnit ?? this.weightUnit,
        activityLevel: activityLevel ?? this.activityLevel,
        goals: goals ?? this.goals,
        targetWeight: targetWeight ?? this.targetWeight,
        dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
        dailyStepsGoal: dailyStepsGoal ?? this.dailyStepsGoal,
        dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      );
}
