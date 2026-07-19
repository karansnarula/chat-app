import 'package:chat_app/core/constants/app_colors.dart';
import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:flutter/material.dart';

/// Hand-rolled shimmer: sweeps a highlight gradient across [child] using
/// a [ShaderMask] driven by a repeating animation. Wrap skeleton shapes
/// (e.g. [ShimmerBox]) in this while content loads.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmerCycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base =
        dark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlight = dark
        ? AppColors.shimmerHighlightDark
        : AppColors.shimmerHighlightLight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          // Slide the gradient from left of the bounds to right of them.
          final dx = bounds.width * (2 * _controller.value - 1) * 2;
          return LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(bounds.shift(Offset(dx, 0)));
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Grey placeholder block used to sketch loading skeletons.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.radius = AppDimens.radiusS,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  const ShimmerBox.circle({required double size, super.key})
      : width = size,
        height = size,
        radius = 0,
        shape = BoxShape.circle;

  final double? width;
  final double? height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            dark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
