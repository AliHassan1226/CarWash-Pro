import 'package:flutter/material.dart';

/// Enum for loading indicator styles
enum LoadingIndicatorStyle {
  circular,
  linear,
  dots,
}

/// Custom Loading Indicator Widget - Comprehensive loading component
/// 
/// Features:
/// - 3 loading styles (circular, linear, dots)
/// - Full screen overlay support
/// - Custom colors
/// - Message/label display
/// - Size customization
/// - Animation control
/// - Null safety
class CustomLoadingIndicator extends StatefulWidget {
  final LoadingIndicatorStyle style;
  final Color color;
  final double size;
  final String? message;
  final bool isFullScreen;
  final Color? backgroundColor;
  final TextStyle? messageStyle;
  final double strokeWidth;
  final Duration animationDuration;
  final bool showMessage;

  const CustomLoadingIndicator({
    super.key,
    this.style = LoadingIndicatorStyle.circular,
    this.color = const Color(0xFF1A73E8),
    this.size = 48,
    this.message,
    this.isFullScreen = false,
    this.backgroundColor,
    this.messageStyle,
    this.strokeWidth = 4,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showMessage = true,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicator = _buildIndicator();

    if (widget.isFullScreen) {
      return Container(
        color: widget.backgroundColor ?? Colors.black.withOpacity(0.3),
        child: Center(
          child: _buildContent(indicator),
        ),
      );
    }

    return Center(
      child: _buildContent(indicator),
    );
  }

  Widget _buildContent(Widget indicator) {
    if (!widget.showMessage || widget.message == null) {
      return indicator;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 16),
        Text(
          widget.message!,
          style: widget.messageStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    switch (widget.style) {
      case LoadingIndicatorStyle.circular:
        return _buildCircularIndicator();
      case LoadingIndicatorStyle.linear:
        return _buildLinearIndicator();
      case LoadingIndicatorStyle.dots:
        return _buildDotsIndicator();
    }
  }

  Widget _buildCircularIndicator() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        strokeWidth: widget.strokeWidth,
      ),
    );
  }

  Widget _buildLinearIndicator() {
    return SizedBox(
      width: widget.size * 2,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        minHeight: widget.strokeWidth,
      ),
    );
  }

  Widget _buildDotsIndicator() {
    const int dotsCount = 3;
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            dotsCount,
            (index) => _buildDot(index, dotsCount),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, int totalDots) {
    final delay = (index * 100) / widget.animationDuration.inMilliseconds;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay,
            delay + 0.5,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: widget.size / 3,
          height: widget.size / 3,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Loading Overlay Widget - Displays a loading indicator as an overlay
/// 
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (context) => const LoadingOverlay(
///     message: 'Loading...',
///   ),
/// );
/// ```
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color color;
  final LoadingIndicatorStyle style;

  const LoadingOverlay({
    super.key,
    this.message,
    this.color = const Color(0xFF1A73E8),
    this.style = LoadingIndicatorStyle.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: CustomLoadingIndicator(
        style: style,
        color: color,
        message: message,
        isFullScreen: true,
        backgroundColor: Colors.black.withOpacity(0.3),
        showMessage: message != null,
      ),
    );
  }
}

/// Shimmer Loading Effect Widget - Displays a shimmer effect while loading
/// 
/// Usage:
/// ```dart
/// ShimmerLoading(
///   isLoading: isLoading,
///   child: YourWidget(),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -1.0),
              end: const Alignment(1.0, 1.0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animationController.value - 0.3,
                _animationController.value,
                _animationController.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton Loading Widget - Displays skeleton loaders while content loads
/// 
/// Usage:
/// ```dart
/// SkeletonLoader(
///   isLoading: isLoading,
///   skeleton: _buildSkeleton(),
///   child: YourActualContent(),
/// )
/// ```
class SkeletonLoader extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;

  const SkeletonLoader({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading ? skeleton : child;
  }
}

/// Skeleton Box Widget - Individual skeleton box component
/// 
/// Usage:
/// ```dart
/// SkeletonBox(
///   width: 200,
///   height: 20,
/// )
/// ```
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animationController.value - 0.3,
                _animationController.value,
                _animationController.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Progress Indicator Widget - Shows progress with label
/// 
/// Usage:
/// ```dart
/// ProgressIndicator(
///   progress: 0.75,
///   label: '75%',
/// )
/// ```
class ProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final Color progressColor;
  final Color backgroundColor;
  final double height;
  final TextStyle? labelStyle;
  final bool showLabel;

  const ProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.progressColor = const Color(0xFF1A73E8),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.height = 6,
    this.labelStyle,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? '${(progress * 100).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loading'),
              Text(
                displayLabel,
                style: labelStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}