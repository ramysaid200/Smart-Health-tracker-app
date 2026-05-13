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
import '../../../../../navigation/app_router.dart';

/// Login screen with email/password and gradient background
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.massive),

                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: _buildHeader(),
                ),

                const SizedBox(height: AppDimensions.xxxl),

                // Form
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 200),
                  child: _buildForm(),
                ),

                const SizedBox(height: AppDimensions.xl),

                // Login Button
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 300),
                  child: _buildLoginButton(),
                ),

                const SizedBox(height: AppDimensions.xl),

                // Register link
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 400),
                  child: _buildFooter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: AppDimensions.xl),
        Text(AppStrings.welcomeBack, style: AppTextStyles.h1),
        const SizedBox(height: AppDimensions.sm),
        Text(AppStrings.loginSubtitle, style: AppTextStyles.bodyMdSecondary),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailCtrl,
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.email,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AppDimensions.base),
          CustomTextField(
            controller: _passwordCtrl,
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            validator: Validators.password,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: AppDimensions.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.forgotPassword),
              child: Text(AppStrings.forgotPassword, style: AppTextStyles.link),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => CustomButton(
        label: AppStrings.login,
        onPressed: _login,
        isLoading: auth.isLoading,
        icon: Icons.login_rounded,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.noAccount, style: AppTextStyles.bodyMdSecondary),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRouter.register),
          child: Text(AppStrings.signUp, style: AppTextStyles.link.copyWith(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
