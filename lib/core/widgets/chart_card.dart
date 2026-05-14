import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';

/// Wrapper card for fl_chart charts with title and optional tabs
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.height = AppDimensions.chartCardHeight,
    this.padding,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? action;
  final double height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h5),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTextStyles.bodySmSecondary),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: AppDimensions.base),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}
