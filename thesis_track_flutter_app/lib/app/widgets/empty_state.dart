import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? color;
  final String? title;
  final Size? buttonSize;
  final IconData? actionIcon;
  final bool isLoading;
  final double? maxWidth;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.color,
    this.title,
    this.buttonSize,
    this.actionIcon,
    this.isLoading = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = this.maxWidth ?? 400.0;
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with background
            Container(
              padding: EdgeInsets.all(AppTheme.spaceMD),
              decoration: BoxDecoration(
                color:
                    color ?? theme.colorScheme.outlineVariant.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Iconsax.direct_inbox,
                size: 48,
                color: color ?? theme.colorScheme.outlineVariant,
              ),
            ),
            SizedBox(height: AppTheme.spaceSM),

            // Title if provided
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spaceSM),
            ],

            // Main message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button if provided
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: AppTheme.spaceXL),
              FilledButton.icon(
                onPressed: isLoading ? null : onAction,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          strokeCap: StrokeCap.round,
                        ),
                      )
                    : Icon(actionIcon ?? Iconsax.add),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  minimumSize: buttonSize,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
