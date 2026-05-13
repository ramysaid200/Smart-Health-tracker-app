import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';

/// Reusable health metric display card
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.subtitle,
    this.progress,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final double? progress; // 0.0 to 1.0
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(icon, color: color, size: AppDimensions.iconMd),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(title, style: AppTextStyles.labelMd),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: value, style: AppTextStyles.metricMd.copyWith(color: color)),
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.bodySmSecondary,
                  ),
                ],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(subtitle!, style: AppTextStyles.bodySmSecondary),
            ],
            if (progress != null) ...[
              const SizedBox(height: AppDimensions.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
