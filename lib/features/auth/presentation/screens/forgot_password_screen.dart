import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';

/// Forgot password screen – sends a password reset email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailCtrl.text);
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.huge),
              FadeInDown(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGlow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    Text(AppStrings.forgotPassword, style: AppTextStyles.h2),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      AppStrings.forgotPasswordSubtitle,
                      style: AppTextStyles.bodyMdSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),
              if (_sent)
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(AppStrings.passwordResetSent, style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: CustomTextField(
                          controller: _emailCtrl,
                          label: AppStrings.email,
                          hint: AppStrings.emailHint,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => CustomButton(
                          label: AppStrings.sendResetLink,
                          onPressed: _send,
                          isLoading: auth.isLoading,
                          icon: Icons.send_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
