import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/health_calculators.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../services/storage_service.dart';

/// Onboarding state manager
class OnboardingProvider extends ChangeNotifier {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  // Step 1: Basic Info
  int age = 25;
  String gender = 'male';
  double heightCm = 170;
  String heightUnit = 'cm';
  double weightKg = 70;
  String weightUnit = 'kg';

  // Step 2: Goals
  List<String> selectedGoals = [];
  double? targetWeight;

  // Step 3: Activity Level
  String activityLevel = 'moderately_active';

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalSteps => 3;
  bool get canGoBack => _currentStep > 0;
  bool get isLastStep => _currentStep == totalSteps - 1;

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else {
      selectedGoals.add(goal);
    }
    notifyListeners();
  }

  void setGender(String g) { gender = g; notifyListeners(); }
  void setActivityLevel(String level) { activityLevel = level; notifyListeners(); }

  Future<bool> completeOnboarding(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bmr = HealthCalculators.calculateBMR(age, weightKg, heightCm, gender);
      final tdee = HealthCalculators.calculateTDEE(bmr, activityLevel);
      final waterGoal = HealthCalculators.calculateWaterGoal(weightKg, activityLevel);
      final stepsGoal = HealthCalculators.getStepGoal(activityLevel);

      final profile = UserProfile(
        age: age,
        gender: gender,
        heightCm: heightCm,
        heightUnit: heightUnit,
        weightKg: weightKg,
        weightUnit: weightUnit,
        activityLevel: activityLevel,
        goals: List.from(selectedGoals),
        targetWeight: targetWeight,
        dailyCalorieGoal: tdee.round(),
        dailyStepsGoal: stepsGoal,
        dailyWaterGoal: waterGoal,
      );

      final authProvider = context.read<AuthProvider>();
      if (authProvider.user == null) {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedUser = authProvider.user!.copyWith(profile: profile);
      final success = await authProvider.updateProfile(updatedUser);

      if (success) {
        // Cache key values locally
        final storage = StorageService.instance;
        await storage.setDailyCalorieGoal(profile.dailyCalorieGoal);
        await storage.setDailyStepsGoal(profile.dailyStepsGoal);
        await storage.setDailyWaterGoal(profile.dailyWaterGoal);
        await storage.setActivityLevel(profile.activityLevel);
        await storage.setUserWeight(profile.weightKg);
        await storage.setUserHeight(profile.heightCm);
        await storage.setOnboardingDone(true);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to save profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
