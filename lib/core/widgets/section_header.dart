import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';

/// Section header with title and optional "View All" action
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h4),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.bodySmSecondary),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                actionLabel!,
                style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
