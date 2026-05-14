import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/water/presentation/providers/water_provider.dart';
import 'core/providers/health_providers.dart';
import 'navigation/app_router.dart';

/// Root MaterialApp with dark theme, named routes, and auth state listener
class SmartHealthTrackerApp extends StatelessWidget {
  const SmartHealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final String userId = auth.firebaseUser?.uid ?? "dev_user";
          final healthProviders = [
            ChangeNotifierProvider(
              create: (_) => HomeProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => WaterProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => StepsProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => NutritionProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => SleepProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => WeightProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => VitalsProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => MedicationProvider(userId),
            ),
            ChangeNotifierProvider(
              create: (_) => WorkoutProvider(userId),
            ),
          ];

          Widget app = MaterialApp(
            title: 'Smart Health Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routes: AppRouter.routes,
            home: HomeScreen(), // Bypass login/initialization check
          );

          if (healthProviders.isNotEmpty) {
            return MultiProvider(
              providers: healthProviders,
              child: app,
            );
          }

          return app;
        },
      ),
    );
  }

  Widget _buildHome(AuthProvider auth) {
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
        ),
      );
    }
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }
    // Authenticated — navigate based on onboarding state
    return const _AuthenticatedHome();
  }
}

/// Handles routing after authentication
class _AuthenticatedHome extends StatelessWidget {
  const _AuthenticatedHome();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final hasProfile = auth.user?.profile != null;
      if (!hasProfile) {
        Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
    );
  }
}
