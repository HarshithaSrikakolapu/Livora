
import 'package:flutter/material.dart';
import 'package:Livora/core/theme/color_palette.dart';

enum AppButtonType { primary, secondary, outline, text, danger }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonType type;
  final IconData? icon;
  final double? width;
  final double height;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.icon,
    this.width,
    this.height = 56, // Modern taller buttons
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.onPressed == null) {
      return theme.disabledColor;
    }
    
    switch (widget.type) {
      case AppButtonType.primary:
        return ColorPalette.livoraRed;
      case AppButtonType.secondary:
        return ColorPalette.darkSurfaceVariant;
      case AppButtonType.danger:
        return ColorPalette.livoraRed; 
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.onPressed == null) {
      return theme.disabledColor.withOpacity(0.6);
    }

    switch (widget.type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return ColorPalette.pureWhite;
      case AppButtonType.secondary:
        return ColorPalette.pureWhite;
      case AppButtonType.outline:
        return ColorPalette.livoraRed;
      case AppButtonType.text:
        return ColorPalette.softGrey;
    }
  }

  BoxBorder? _getBorder() {
    if (widget.type == AppButtonType.outline && widget.onPressed != null) {
      return Border.all(color: ColorPalette.borderSubtle, width: 1.5);
    }
    return null;
  }

  List<BoxShadow> _getShadows() {
    if (widget.type == AppButtonType.primary && widget.onPressed != null && !_isPressed) {
      return [
        BoxShadow(
          color: Colors.white.withOpacity(_isHovered ? 0.2 : 0.1),
          blurRadius: _isHovered ? 12 : 8,
          offset: Offset(0, _isHovered ? 6 : 4),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
           if (widget.onPressed == null) return;
           setState(() => _isPressed = true);
           _controller.forward();
        },
        onTapUp: (_) {
          if (widget.onPressed == null) return;
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          if (widget.onPressed == null) return;
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.fullWidth ? double.infinity : widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _getBackgroundColor(theme),
              borderRadius: BorderRadius.circular(14),
              border: _getBorder(),
              boxShadow: _getShadows(),
            ),
            child: widget.isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: _getTextColor(theme),
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: _getTextColor(theme),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _getTextColor(theme),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
