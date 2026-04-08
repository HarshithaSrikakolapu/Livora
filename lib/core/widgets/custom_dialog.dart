import 'package:flutter/material.dart';
import 'package:Livora/core/theme/color_palette.dart';

enum DialogType { info, success, error, warning, confirmation }

class CustomDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final DialogType type;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.type = DialogType.info,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    DialogType type = DialogType.info,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => const SizedBox(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: a1,
            child: CustomDialog(
              title: title,
              message: message,
              primaryButtonText: primaryButtonText,
              onPrimaryPressed: onPrimaryPressed,
              secondaryButtonText: secondaryButtonText,
              onSecondaryPressed: onSecondaryPressed,
              type: type,
            ),
          ),
        );
      },
    );
  }

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  Color _getTypeColor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      switch (widget.type) {
        case DialogType.error: return ColorPalette.error;
        case DialogType.warning: return ColorPalette.warning;
        case DialogType.success: return ColorPalette.success;
        default: return theme.primaryColor;
      }
    }
    
    switch (widget.type) {
      case DialogType.error: return ColorPalette.error;
      case DialogType.warning: return ColorPalette.warning;
      case DialogType.success: return ColorPalette.success;
      default: return theme.primaryColor;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case DialogType.error: return Icons.error_outline_rounded;
      case DialogType.warning: return Icons.warning_amber_rounded;
      case DialogType.success: return Icons.check_circle_outline_rounded;
      case DialogType.confirmation: return Icons.help_outline_rounded;
      case DialogType.info: return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _getTypeColor(theme);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(),
                color: accentColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              widget.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              children: [
                if (widget.secondaryButtonText != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.onSecondaryPressed?.call();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.secondaryButtonText!,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onPrimaryPressed?.call();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.primaryButtonText ?? 'OK',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
