import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/steps/presentation/screens/steps_screen.dart';
import '../features/water/presentation/screens/water_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../features/nutrition/presentation/screens/add_meal_screen.dart';
import '../features/workouts/presentation/screens/workouts_screen.dart';
import '../features/workouts/presentation/screens/add_workout_screen.dart';
import '../features/sleep/presentation/screens/sleep_screen.dart';
import '../features/sleep/presentation/screens/add_sleep_screen.dart';
import '../features/weight/presentation/screens/weight_screen.dart';
import '../features/weight/presentation/screens/add_weight_screen.dart';
import '../features/vitals/presentation/screens/vitals_screen.dart';
import '../features/vitals/presentation/screens/add_vitals_screen.dart';
import '../features/medications/presentation/screens/medications_screen.dart';
import '../features/medications/presentation/screens/add_medication_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';

/// Named route configuration for the entire app
class AppRouter {
  AppRouter._();

  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String steps = '/steps';
  static const String water = '/water';
  static const String nutrition = '/nutrition';
  static const String addMeal = '/nutrition/add-meal';
  static const String workouts = '/workouts';
  static const String addWorkout = '/workouts/add';
  static const String sleep = '/sleep';
  static const String addSleep = '/sleep/add';
  static const String weight = '/weight';
  static const String addWeight = '/weight/add';
  static const String vitals = '/vitals';
  static const String addVitals = '/vitals/add';
  static const String medications = '/medications';
  static const String addMedication = '/medications/add';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        onboarding: (_) => const OnboardingScreen(),
        home: (_) => const HomeScreen(),
        steps: (_) => const StepsScreen(),
        water: (_) => const WaterScreen(),
        nutrition: (_) => const NutritionScreen(),
        addMeal: (_) => const AddMealScreen(),
        workouts: (_) => const WorkoutsScreen(),
        addWorkout: (_) => const AddWorkoutScreen(),
        sleep: (_) => const SleepScreen(),
        addSleep: (_) => const AddSleepScreen(),
        weight: (_) => const WeightScreen(),
        addWeight: (_) => const AddWeightScreen(),
        vitals: (_) => const VitalsScreen(),
        addVitals: (_) => const AddVitalsScreen(),
        medications: (_) => const MedicationsScreen(),
        addMedication: (_) => const AddMedicationScreen(),
        analytics: (_) => const AnalyticsScreen(),
        profile: (_) => const ProfileScreen(),
        editProfile: (_) => const EditProfileScreen(),
        settings: (_) => const SettingsScreen(),
      };

  /// Slide transition route factory
  static Route<T> slideRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => screen,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition route factory
  static Route<T> fadeRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => screen,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
