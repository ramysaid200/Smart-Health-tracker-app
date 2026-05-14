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

/// Register screen with name, email, password fields and terms checkbox
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.agreedToTermsRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailCtrl.text,
      _passwordCtrl.text,
      _nameCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
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
                const SizedBox(height: AppDimensions.huge),
                FadeInDown(
                  child: Column(
                    children: [
                      Text(AppStrings.createAccount, style: AppTextStyles.h1),
                      const SizedBox(height: AppDimensions.sm),
                      Text(AppStrings.registerSubtitle, style: AppTextStyles.bodyMdSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xxl),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildForm(),
                ),
                const SizedBox(height: AppDimensions.base),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildTermsCheckbox(),
                ),
                const SizedBox(height: AppDimensions.xl),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildRegisterButton(),
                ),
                const SizedBox(height: AppDimensions.xl),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildFooter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameCtrl,
            label: AppStrings.fullName,
            hint: AppStrings.nameHint,
            prefixIcon: Icons.person_outline,
            validator: Validators.name,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: AppDimensions.base),
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
          ),
          const SizedBox(height: AppDimensions.base),
          CustomTextField(
            controller: _confirmCtrl,
            label: AppStrings.confirmPassword,
            hint: AppStrings.passwordHint,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
        ),
        Expanded(
          child: Text(AppStrings.agreeToTerms, style: AppTextStyles.bodyMd),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => CustomButton(
        label: AppStrings.signUp,
        onPressed: _register,
        isLoading: auth.isLoading,
        icon: Icons.person_add_rounded,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.hasAccount, style: AppTextStyles.bodyMdSecondary),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          child: Text(AppStrings.login, style: AppTextStyles.link.copyWith(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
