import 'package:flutter/material.dart';

/// Enum for button variants/styles
enum ButtonVariant {
  primary,
  secondary,
  success,
  error,
  warning,
  outlined,
  ghost,
}

/// Enum for button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Custom Button Widget - Comprehensive button component with multiple variants
/// 
/// Features:
/// - 7 button variants (primary, secondary, success, error, warning, outlined, ghost)
/// - 3 size options (small, medium, large)
/// - Loading state with spinner
/// - Icon and text combination
/// - Full width option
/// - Custom colors and styling
/// - Scale animation on press
/// - Disabled state handling
/// - Null safety
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final bool hasBorder;
  final Color? borderColor;
  final TextStyle? textStyle;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.hasBorder = false,
    this.borderColor,
    this.textStyle,
    this.child,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressed() {
    if (widget.isLoading || widget.onPressed == null) return;

    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onPressed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final colors = _getButtonColors();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : null,
        height: _getButtonHeight(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : _onPressed,
            borderRadius: widget.borderRadius,
            highlightColor: colors.backgroundColor.withOpacity(0.2),
            splashColor: colors.backgroundColor.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey[300]
                    : (widget.backgroundColor ?? colors.backgroundColor),
                borderRadius: widget.borderRadius,
                border: widget.hasBorder
                    ? Border.all(
                        color: widget.borderColor ?? colors.backgroundColor,
                        width: 2,
                      )
                    : null,
                boxShadow: widget.elevation != null
                    ? [
                        BoxShadow(
                          color: (widget.backgroundColor ?? colors.backgroundColor)
                              .withOpacity(0.3),
                          blurRadius: widget.elevation ?? 0,
                          offset: Offset(0, (widget.elevation ?? 0) / 2),
                        ),
                      ]
                    : null,
              ),
              padding: widget.padding,
              child: _buildButtonContent(isDisabled, colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isDisabled, _ButtonColors colors) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getLoadingIndicatorSize(),
          height: _getLoadingIndicatorSize(),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.textColor ?? colors.textColor,
            ),
            strokeWidth: 2,
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.label,
      style: widget.textStyle ??
          TextStyle(
            color: isDisabled ? Colors.grey[600] : (widget.textColor ?? colors.textColor),
            fontWeight: FontWeight.w600,
            fontSize: _getTextSize(),
          ),
    );

    if (widget.icon == null && widget.child == null) {
      return Center(child: textWidget);
    }

    if (widget.child != null) {
      return widget.child!;
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: isDisabled ? Colors.grey[600] : (widget.textColor ?? colors.textColor),
            size: _getIconSize(),
          ),
          const SizedBox(width: 8),
          textWidget,
        ],
      ),
    );
  }

  _ButtonColors _getButtonColors() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: const Color(0xFF1A73E8),
          textColor: Colors.white,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: const Color(0xFF34A853),
          textColor: Colors.white,
        );
      case ButtonVariant.success:
        return _ButtonColors(
          backgroundColor: const Color(0xFF34A853),
          textColor: Colors.white,
        );
      case ButtonVariant.error:
        return _ButtonColors(
          backgroundColor: const Color(0xFFEA4335),
          textColor: Colors.white,
        );
      case ButtonVariant.warning:
        return _ButtonColors(
          backgroundColor: const Color(0xFFFBBC04),
          textColor: Colors.white,
        );
      case ButtonVariant.outlined:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: const Color(0xFF1A73E8),
        );
      case ButtonVariant.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: const Color(0xFF1A73E8),
        );
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getTextSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getLoadingIndicatorSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

/// Button colors helper class
class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
  });
}