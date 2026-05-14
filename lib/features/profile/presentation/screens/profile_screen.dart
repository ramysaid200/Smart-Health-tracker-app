import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../../navigation/bottom_nav_bar.dart';
import '../../../../../navigation/app_router.dart';
import '../../../../../services/storage_service.dart';

/// Profile screen with user info and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 4,
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false, actions: [
              IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.editProfile)),
            ]),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(children: [
                FadeInDown(child: _buildAvatar(user?.name ?? 'User')),
                const SizedBox(height: AppDimensions.sm),
                Text(user?.name ?? 'User', style: AppTextStyles.h3),
                Text(user?.email ?? '', style: AppTextStyles.bodyMdSecondary),
                if (user?.createdAt != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text('Member since ${_formatDate(user!.createdAt)}', style: AppTextStyles.bodySmSecondary),
                ],
                const SizedBox(height: AppDimensions.xxl),
                FadeInUp(delay: const Duration(milliseconds: 100), child: _buildHealthInfo(user?.profile)),
                const SizedBox(height: AppDimensions.xl),
                FadeInUp(delay: const Duration(milliseconds: 200), child: _buildQuickLinks(context)),
                const SizedBox(height: AppDimensions.xl),
                FadeInUp(delay: const Duration(milliseconds: 300), child: _buildLogout(context, auth)),
                const SizedBox(height: AppDimensions.massive),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: AppDimensions.avatarXl,
      height: AppDimensions.avatarXl,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'Y', style: AppTextStyles.h1.copyWith(color: Colors.white))),
    );
  }

  Widget _buildHealthInfo(profile) {
    if (profile == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Health Profile', style: AppTextStyles.h5),
        const SizedBox(height: AppDimensions.base),
        _InfoRow(label: 'Age', value: '${profile.age} years'),
        _InfoRow(label: 'Height', value: '${profile.heightCm.toStringAsFixed(0)} cm'),
        _InfoRow(label: 'Weight', value: '${profile.weightKg.toStringAsFixed(1)} ${profile.weightUnit}'),
        _InfoRow(label: 'Activity', value: profile.activityLevel.replaceAll('_', ' ')),
        _InfoRow(label: 'Calorie Goal', value: '${profile.dailyCalorieGoal} kcal', last: true),
      ]),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      {'icon': Icons.directions_walk_rounded, 'label': 'Steps', 'route': AppRouter.steps, 'color': AppColors.stepsColor},
      {'icon': Icons.water_drop_rounded, 'label': 'Water', 'route': AppRouter.water, 'color': AppColors.waterColor},
      {'icon': Icons.bedtime_rounded, 'label': 'Sleep', 'route': AppRouter.sleep, 'color': AppColors.sleepColor},
      {'icon': Icons.monitor_weight_rounded, 'label': 'Weight', 'route': AppRouter.weight, 'color': AppColors.weightColor},
      {'icon': Icons.favorite_rounded, 'label': 'Vitals', 'route': AppRouter.vitals, 'color': AppColors.heartColor},
      {'icon': Icons.medication_rounded, 'label': 'Medications', 'route': AppRouter.medications, 'color': AppColors.error},
      {'icon': Icons.bar_chart_rounded, 'label': 'Analytics', 'route': AppRouter.analytics, 'color': AppColors.primary},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'route': AppRouter.settings, 'color': AppColors.textSecondary},
    ];

    return Container(
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(
        children: links.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == links.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(item['icon'] as IconData, color: item['color'] as Color),
              title: Text(item['label'] as String, style: AppTextStyles.bodyMd),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () => Navigator.pushNamed(context, item['route'] as String),
            ),
            if (!isLast) const Divider(height: 1, indent: 56),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildLogout(BuildContext context, AuthProvider auth) {
    return CustomButton(
      label: 'Logout',
      onPressed: () async {
        await auth.logout();
        if (context.mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
      },
      color: AppColors.error,
      icon: Icons.logout_rounded,
    );
  }

  String _formatDate(DateTime d) => '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});
  final String label; final String value; final bool last;

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(children: [
        Text(label, style: AppTextStyles.bodyMdSecondary),
        const Spacer(),
        Text(value, style: AppTextStyles.labelLg),
      ]),
    ),
    if (!last) const Divider(height: 1),
  ]);
}
