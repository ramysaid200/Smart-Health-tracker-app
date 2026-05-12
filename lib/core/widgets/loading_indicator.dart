import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Shimmer loading indicator for cards and list items
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.isCard = true});
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: isCard ? _buildCardShimmer() : _buildListShimmer(),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      height: AppDimensions.shimmerCardHeight,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
    );
  }

  Widget _buildListShimmer() {
    return Column(
      children: List.generate(
        4,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Container(
            height: AppDimensions.shimmerListItemHeight,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer for a chart area
class ChartShimmer extends StatelessWidget {
  const ChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: AppDimensions.shimmerChartHeight,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),
    );
  }
}

/// Full page loading spinner
class FullPageLoader extends StatelessWidget {
  const FullPageLoader({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.base),
            Text(message!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
