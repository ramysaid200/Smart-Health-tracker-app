/// Health metric calculation utilities
/// Based on established medical formulas
class HealthCalculators {
  HealthCalculators._();

  /// Calculate BMI (Body Mass Index)
  /// [weightKg] weight in kilograms
  /// [heightCm] height in centimeters
  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category label
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Calculate BMR using Mifflin-St Jeor equation
  /// [age] in years, [weightKg], [heightCm], [gender] 'male'|'female'
  static double calculateBMR(int age, double weightKg, double heightCm, String gender) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 0;
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender.toLowerCase() == 'male' ? base + 5 : base - 161;
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    const multipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'athlete': 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.2);
  }

  /// Calculate calories burned during a workout (simplified MET approach)
  static double calculateWorkoutCalories({
    required String workoutType,
    required int durationMinutes,
    required double weightKg,
    required String intensity,
  }) {
    const metValues = {
      'running': 9.8,
      'walking': 3.8,
      'cycling': 8.0,
      'swimming': 8.3,
      'strength': 6.0,
      'yoga': 3.0,
      'hiit': 10.0,
    };
    const intensityMultipliers = {
      'low': 0.7,
      'moderate': 1.0,
      'high': 1.3,
      'intense': 1.6,
    };

    final met = metValues[workoutType] ?? 5.0;
    final multiplier = intensityMultipliers[intensity] ?? 1.0;
    return met * weightKg * (durationMinutes / 60) * multiplier;
  }

  /// Calculate daily water goal (in glasses of 250ml each)
  /// Based on weight and activity level
  static int calculateWaterGoal(double weightKg, String activityLevel) {
    double baseGlasses = weightKg * 0.033 / 0.25; // 33ml per kg, converted to 250ml glasses
    const activityBonus = {
      'sedentary': 0.0,
      'lightly_active': 1.0,
      'moderately_active': 2.0,
      'very_active': 3.0,
      'athlete': 4.0,
    };
    return (baseGlasses + (activityBonus[activityLevel] ?? 0)).round().clamp(6, 16);
  }

  /// Estimate daily step goal based on activity level
  static int getStepGoal(String activityLevel) {
    const goals = {
      'sedentary': 6000,
      'lightly_active': 8000,
      'moderately_active': 10000,
      'very_active': 12000,
      'athlete': 15000,
    };
    return goals[activityLevel] ?? 10000;
  }

  /// Calculate projected date to reach goal weight
  /// Based on a deficit/surplus of ~500 kcal/day = ~0.5kg/week
  static DateTime? projectGoalDate(double currentWeight, double goalWeight) {
    final diff = (currentWeight - goalWeight).abs();
    if (diff < 0.1) return null;
    final weeksNeeded = diff / 0.5; // ~0.5kg per week
    return DateTime.now().add(Duration(days: (weeksNeeded * 7).round()));
  }

  /// Convert weight from lbs to kg
  static double lbsToKg(double lbs) => lbs * 0.453592;

  /// Convert weight from kg to lbs
  static double kgToLbs(double kg) => kg * 2.20462;

  /// Convert height from cm to feet and inches
  static (int feet, int inches) cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return (feet, inches);
  }

  /// Convert feet and inches to cm
  static double feetInchesToCm(int feet, int inches) => ((feet * 12) + inches) * 2.54;

  /// Classify blood pressure
  static String classifyBloodPressure(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'High Stage 1';
    return 'High Stage 2';
  }

  /// Calculate sleep quality score from duration (hours) and quality string
  static double sleepQualityScore(double durationHours, String quality) {
    double base = (durationHours / 8.0).clamp(0, 1) * 70;
    const qualityBonus = {'poor': 0.0, 'fair': 10.0, 'good': 20.0, 'excellent': 30.0};
    return (base + (qualityBonus[quality] ?? 0)).clamp(0, 100);
  }

  /// Calculate macro percentages
  static Map<String, double> calculateMacroPercentages({
    required double protein,
    required double carbs,
    required double fats,
  }) {
    final totalCalories = (protein * 4) + (carbs * 4) + (fats * 9);
    if (totalCalories <= 0) return {'protein': 0, 'carbs': 0, 'fats': 0};
    return {
      'protein': (protein * 4 / totalCalories) * 100,
      'carbs': (carbs * 4 / totalCalories) * 100,
      'fats': (fats * 9 / totalCalories) * 100,
    };
  }
}
