import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';
import 'custom_button.dart';

/// Error display widget with retry button
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: AppDimensions.iconMd),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Text(message, style: AppTextStyles.bodySm.copyWith(color: AppColors.error))),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Oops!', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.sm),
            Text(message, style: AppTextStyles.bodyMdSecondary, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                width: 160,
                child: CustomButton(label: 'Try Again', onPressed: onRetry, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
