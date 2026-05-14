import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';
import 'custom_button.dart';

/// Empty state with icon, message, and optional CTA
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: AppDimensions.iconHuge,
                color: c.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(title, style: AppTextStyles.h4, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.sm),
            Text(subtitle, style: AppTextStyles.bodyMdSecondary, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                width: 180,
                child: CustomButton(label: actionLabel!, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
