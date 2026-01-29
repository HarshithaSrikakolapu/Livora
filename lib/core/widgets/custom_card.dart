import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final Border? border;

  const CustomCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.elevation,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
    final borderRadius = shape?.borderRadius as BorderRadius? ?? BorderRadius.circular(18);

    return Container(
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
