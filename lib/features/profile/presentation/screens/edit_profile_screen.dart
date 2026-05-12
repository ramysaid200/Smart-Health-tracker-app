import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Edit profile screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  late String _gender;
  late int _age;
  late double _heightCm;
  late double _weightKg;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
    _gender = user?.profile?.gender ?? 'male';
    _age = user?.profile?.age ?? 25;
    _heightCm = user?.profile?.heightCm ?? 170;
    _weightKg = user?.profile?.weightKg ?? 70;
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    final updatedUser = auth.user!.copyWith(name: _nameCtrl.text.trim());
    await auth.updateProfile(updatedUser);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Display Name', style: AppTextStyles.labelLg),
          const SizedBox(height: AppDimensions.xs),
          TextField(controller: _nameCtrl, style: AppTextStyles.bodyMd, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: AppDimensions.xl),
          Text('Age: $_age years', style: AppTextStyles.bodyMd),
          Slider(value: _age.toDouble(), min: 10, max: 100, divisions: 90, label: '$_age', onChanged: (v) => setState(() => _age = v.round())),
          const SizedBox(height: AppDimensions.base),
          Text('Height: ${_heightCm.toStringAsFixed(0)} cm', style: AppTextStyles.bodyMd),
          Slider(value: _heightCm, min: 100, max: 250, divisions: 150, label: '${_heightCm.toStringAsFixed(0)} cm', onChanged: (v) => setState(() => _heightCm = v)),
          const SizedBox(height: AppDimensions.base),
          Text('Weight: ${_weightKg.toStringAsFixed(1)} kg', style: AppTextStyles.bodyMd),
          Slider(value: _weightKg, min: 30, max: 200, divisions: 340, label: '${_weightKg.toStringAsFixed(1)} kg', onChanged: (v) => setState(() => _weightKg = v)),
          const SizedBox(height: AppDimensions.xxxl),
          Consumer<AuthProvider>(builder: (_, auth, __) => CustomButton(label: 'Save Changes', onPressed: _save, isLoading: auth.isLoading, icon: Icons.save_rounded)),
        ]),
      ),
    );
  }
}

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _useMetric = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
      body: ListView(padding: const EdgeInsets.all(AppDimensions.screenPadding), children: [
        _buildSection('Preferences', [
          _SettingTile(icon: Icons.straighten_rounded, title: 'Units', subtitle: _useMetric ? 'Metric (kg, cm)' : 'Imperial (lbs, in)', trailing: Switch(value: _useMetric, onChanged: (v) => setState(() => _useMetric = v))),
          _SettingTile(icon: Icons.notifications_rounded, title: 'Notifications', subtitle: _notifications ? 'Enabled' : 'Disabled', trailing: Switch(value: _notifications, onChanged: (v) => setState(() => _notifications = v))),
          const _SettingTile(icon: Icons.dark_mode_rounded, title: 'Dark Mode', subtitle: 'Always on', trailing: Icon(Icons.check_circle_rounded, color: AppColors.success)),
        ]),
        const SizedBox(height: AppDimensions.xl),
        _buildSection('About', [
          const _SettingTile(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy', trailing: Icon(Icons.chevron_right_rounded)),
          const _SettingTile(icon: Icons.article_rounded, title: 'Terms of Service', trailing: Icon(Icons.chevron_right_rounded)),
          const _SettingTile(icon: Icons.info_rounded, title: 'App Version', subtitle: '1.0.0'),
        ]),
      ]),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTextStyles.h5),
      const SizedBox(height: AppDimensions.sm),
      Container(
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
        child: Column(children: items.asMap().entries.map((e) => Column(children: [e.value, if (e.key < items.length - 1) const Divider(height: 1)])).toList()),
      ),
    ]);
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, this.subtitle, this.trailing});
  final IconData icon; final String title; final String? subtitle; final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title, style: AppTextStyles.bodyMd),
    subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.bodySmSecondary) : null,
    trailing: trailing,
  );
}
