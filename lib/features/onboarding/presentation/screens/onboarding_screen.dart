import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/onboarding_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../navigation/app_router.dart';

/// Multi-step onboarding screen (3 steps with animated transitions)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(OnboardingProvider p) {
    if (p.isLastStep) {
      _complete(p);
      return;
    }
    p.nextStep();
    _pageController.animateToPage(
      p.currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _back(OnboardingProvider p) {
    p.prevStep();
    _pageController.animateToPage(
      p.currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _complete(OnboardingProvider p) async {
    final success = await p.completeOnboarding(context);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else if (p.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(p.error!), backgroundColor: AppColors.error),
      );
      p.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, p, _) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(p),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Step1BasicInfo(provider: p),
                      _Step2Goals(provider: p),
                      _Step3Activity(provider: p),
                    ],
                  ),
                ),
                _buildBottomBar(p),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(OnboardingProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
        vertical: AppDimensions.base,
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(p.totalSteps, (i) {
              final isActive = i <= p.currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: EdgeInsets.only(right: i < p.totalSteps - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Step ${p.currentStep + 1} of ${p.totalSteps}',
              style: AppTextStyles.bodySmSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(OnboardingProvider p) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Row(
        children: [
          if (p.canGoBack) ...[
            SizedBox(
              width: 56,
              height: AppDimensions.buttonHeightLg,
              child: OutlinedButton(
                onPressed: () => _back(p),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
          ],
          Expanded(
            child: CustomButton(
              label: p.isLastStep ? AppStrings.completeSetup : AppStrings.next,
              onPressed: () => _next(p),
              isLoading: p.isLoading,
              icon: p.isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1: Basic Info
// ─────────────────────────────────────────────────────────────────────────────

class _Step1BasicInfo extends StatefulWidget {
  const _Step1BasicInfo({required this.provider});
  final OnboardingProvider provider;

  @override
  State<_Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<_Step1BasicInfo> {
  OnboardingProvider get p => widget.provider;

  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ageCtrl.text = p.age.toString();
    _heightCtrl.text = p.heightCm.toString();
    _weightCtrl.text = p.weightKg.toString();
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.onboardingTitle1, style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.sm),
            Text(AppStrings.onboardingSubtitle1, style: AppTextStyles.bodyMdSecondary),
            const SizedBox(height: AppDimensions.xxl),

            // Age
            Text('Age', style: AppTextStyles.labelLg),
            const SizedBox(height: AppDimensions.xs),
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMd,
              onChanged: (v) => p.age = int.tryParse(v) ?? p.age,
              decoration: const InputDecoration(hintText: 'e.g. 25', prefixIcon: Icon(Icons.cake_outlined)),
            ),
            const SizedBox(height: AppDimensions.base),

            // Gender
            Text('Gender', style: AppTextStyles.labelLg),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.sm,
              children: ['male', 'female', 'other', 'prefer_not_to_say'].map((g) {
                final isSelected = p.gender == g;
                return ChoiceChip(
                  label: Text(g.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
                  selected: isSelected,
                  onSelected: (_) => p.setGender(g),
                  selectedColor: AppColors.primaryGlow,
                  labelStyle: AppTextStyles.bodyMd.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.base),

            // Height
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Height (cm)', style: AppTextStyles.labelLg),
                      const SizedBox(height: AppDimensions.xs),
                      TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyMd,
                        onChanged: (v) => p.heightCm = double.tryParse(v) ?? p.heightCm,
                        decoration: const InputDecoration(hintText: 'e.g. 170'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight (kg)', style: AppTextStyles.labelLg),
                      const SizedBox(height: AppDimensions.xs),
                      TextField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyMd,
                        onChanged: (v) => p.weightKg = double.tryParse(v) ?? p.weightKg,
                        decoration: const InputDecoration(hintText: 'e.g. 70'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: Goals
// ─────────────────────────────────────────────────────────────────────────────

class _Step2Goals extends StatelessWidget {
  const _Step2Goals({required this.provider});
  final OnboardingProvider provider;

  static const List<Map<String, dynamic>> _goals = [
    {'key': 'lose_weight', 'label': 'Lose Weight', 'icon': Icons.trending_down_rounded},
    {'key': 'gain_muscle', 'label': 'Gain Muscle', 'icon': Icons.fitness_center_rounded},
    {'key': 'stay_active', 'label': 'Stay Active', 'icon': Icons.directions_run_rounded},
    {'key': 'better_sleep', 'label': 'Better Sleep', 'icon': Icons.bedtime_rounded},
    {'key': 'track_nutrition', 'label': 'Track Nutrition', 'icon': Icons.restaurant_rounded},
    {'key': 'manage_medications', 'label': 'Manage Medications', 'icon': Icons.medication_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.onboardingTitle2, style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.sm),
            Text(AppStrings.onboardingSubtitle2, style: AppTextStyles.bodyMdSecondary),
            const SizedBox(height: AppDimensions.xxl),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.sm,
              mainAxisSpacing: AppDimensions.sm,
              childAspectRatio: 2.0,
              children: _goals.map((goal) {
                final isSelected = provider.selectedGoals.contains(goal['key']);
                return GestureDetector(
                  onTap: () => provider.toggleGoal(goal['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGlow : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          goal['icon'] as IconData,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          size: AppDimensions.iconMd,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            goal['label'] as String,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3: Activity Level
// ─────────────────────────────────────────────────────────────────────────────

class _Step3Activity extends StatelessWidget {
  const _Step3Activity({required this.provider});
  final OnboardingProvider provider;

  static const List<Map<String, dynamic>> _levels = [
    {'key': 'sedentary', 'label': 'Sedentary', 'desc': 'Office job, minimal exercise', 'icon': Icons.chair_outlined},
    {'key': 'lightly_active', 'label': 'Lightly Active', 'desc': 'Light exercise 1–3 days/week', 'icon': Icons.directions_walk_rounded},
    {'key': 'moderately_active', 'label': 'Moderately Active', 'desc': 'Moderate exercise 3–5 days/week', 'icon': Icons.directions_run_rounded},
    {'key': 'very_active', 'label': 'Very Active', 'desc': 'Hard exercise 6–7 days/week', 'icon': Icons.electric_bolt_rounded},
    {'key': 'athlete', 'label': 'Athlete', 'desc': 'Physical job + daily training', 'icon': Icons.emoji_events_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.onboardingTitle3, style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.sm),
            Text(AppStrings.onboardingSubtitle3, style: AppTextStyles.bodyMdSecondary),
            const SizedBox(height: AppDimensions.xxl),
            ..._levels.map((level) {
              final isSelected = provider.activityLevel == level['key'];
              return GestureDetector(
                onTap: () {
                  provider.setActivityLevel(level['key'] as String);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                  padding: const EdgeInsets.all(AppDimensions.cardPadding),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGlow : AppColors.surface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Icon(
                          level['icon'] as IconData,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.base),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level['label'] as String,
                              style: AppTextStyles.h5.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            Text(level['desc'] as String, style: AppTextStyles.bodySmSecondary),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
