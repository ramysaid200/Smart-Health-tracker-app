import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
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
          return MultiProvider(
            providers: [
              // Only create these providers when auth is available
              if (auth.firebaseUser != null) ...[
                ChangeNotifierProvider(
                  create: (_) => HomeProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => WaterProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => StepsProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => NutritionProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => SleepProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => WeightProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => VitalsProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => MedicationProvider(auth.firebaseUser!.uid),
                ),
                ChangeNotifierProvider(
                  create: (_) => WorkoutProvider(auth.firebaseUser!.uid),
                ),
              ],
            ],
            child: MaterialApp(
              title: 'Smart Health Tracker',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              routes: AppRouter.routes,
              home: _buildHome(auth),
            ),
          );
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
