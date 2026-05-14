import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';

/// Reusable animated button with gradient, loading state, and scale animation
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.textColor,
    this.height = AppDimensions.buttonHeightLg,
    this.width = double.infinity,
    this.borderRadius = AppDimensions.buttonRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double height;
  final double width;
  final double borderRadius;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final bgColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : (isDisabled ? bgColor.withValues(alpha: 0.5) : bgColor),
            gradient: widget.isOutlined
                ? null
                : (isDisabled
                    ? null
                    : LinearGradient(
                        colors: [bgColor, bgColor.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
            border: widget.isOutlined
                ? Border.all(color: isDisabled ? AppColors.textHint : bgColor, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isOutlined || isDisabled
                ? null
                : [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.textPrimary),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: AppDimensions.iconMd,
                          color: widget.isOutlined
                              ? (isDisabled ? AppColors.textHint : bgColor)
                              : (widget.textColor ?? AppColors.textPrimary),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.buttonLg.copyWith(
                          color: widget.isOutlined
                              ? (isDisabled ? AppColors.textHint : bgColor)
                              : (widget.textColor ?? AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
