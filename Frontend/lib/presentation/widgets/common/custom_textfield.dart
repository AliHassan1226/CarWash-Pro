import 'package:flutter/material.dart';

/// Enum for textfield variants/styles
enum TextFieldVariant {
  outlined,
  filled,
  underline,
}

/// Custom TextField Widget - Comprehensive text input component
/// 
/// Features:
/// - 3 variants (outlined, filled, underline)
/// - Password field with visibility toggle
/// - Input validation with error messages
/// - Clear button for non-empty fields
/// - Prefix and suffix icon support
/// - Character counter
/// - Required field indicator
/// - Multiline support
/// - Focus management
/// - Null safety
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool isPassword;
  final bool isRequired;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextFieldVariant variant;
  final bool showCounter;
  final bool showClearButton;
  final Color? fillColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.isPassword = false,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.variant = TextFieldVariant.outlined,
    this.showCounter = false,
    this.showClearButton = false,
    this.fillColor,
    this.borderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _clearText() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  widget.label!,
                  style: widget.labelStyle ??
                      const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
                if (widget.isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          obscureText: widget.isPassword && !_isPasswordVisible,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: (value) {
            _errorMessage = widget.validator?.call(value);
            return _errorMessage;
          },
          style: widget.textStyle ?? const TextStyle(fontSize: 14),
          decoration: _buildInputDecoration(),
        ),
        if (_errorMessage != null && _errorMessage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    Widget? suffixIcon;

    if (widget.isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: _togglePasswordVisibility,
      );
    } else if (widget.showClearButton && _controller.text.isNotEmpty) {
      suffixIcon = IconButton(
        icon: const Icon(Icons.clear),
        onPressed: _clearText,
      );
    } else if (widget.suffixIcon != null) {
      suffixIcon = IconButton(
        icon: Icon(widget.suffixIcon),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return InputDecoration(
          hintText: widget.hint,
          labelText: widget.label,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          counter: widget.showCounter ? null : const SizedBox.shrink(),
        );

      case TextFieldVariant.filled:
        return InputDecoration(
          hintText: widget.hint,
          labelText: widget.label,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: widget.fillColor ?? Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          counter: widget.showCounter ? null : const SizedBox.shrink(),
        );

      case TextFieldVariant.underline:
        return InputDecoration(
          hintText: widget.hint,
          labelText: widget.label,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: suffixIcon,
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          counter: widget.showCounter ? null : const SizedBox.shrink(),
        );
    }
  }
}