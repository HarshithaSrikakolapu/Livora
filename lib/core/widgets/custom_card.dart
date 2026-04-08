
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Livora/core/theme/color_palette.dart';

class CustomCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin; 
  final Color? color;
  final double? elevation;
  final Border? border;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.border,
    this.borderRadius,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
    final defaultRadius = shape?.borderRadius as BorderRadius? ?? BorderRadius.circular(16);
    final effectiveRadius = widget.borderRadius ?? defaultRadius;
    
    // Safely extract border side from theme if it exists and is an OutlinedBorder
    BorderSide? themeBorderSide;
    if (theme.cardTheme.shape is OutlinedBorder) {
      themeBorderSide = (theme.cardTheme.shape as OutlinedBorder).side;
    }

    // Subtle scale or elevation change on hover
    final hoverElevation = 8.0;
    final defaultElevation = widget.elevation ?? 0.0;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ClipRRect(
          borderRadius: effectiveRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuart,
              transform: _isHovered && widget.onTap != null 
                  ? (Matrix4.identity()..translate(0, -2)) 
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: widget.color ?? (isDark 
                    ? ColorPalette.darkSurfaceVariant.withOpacity(0.6) 
                    : Colors.white.withOpacity(0.7)),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
                border: widget.border ?? Border.all(
                  color: ColorPalette.borderSubtle.withOpacity(0.2), 
                  width: 1.5,
                ),
                boxShadow: [
                  if (_isHovered && widget.onTap != null)
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  else if (defaultElevation > 0)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: effectiveRadius,
                splashColor: theme.primaryColor.withOpacity(0.1),
                highlightColor: theme.primaryColor.withOpacity(0.05),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  child: widget.child,
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
