import 'package:flutter/material.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';

class ThesisCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final Widget? child;
  final bool hasBorder;
  final bool isSelected;
  final double? width;

  const ThesisCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.child,
    this.hasBorder = false,
    this.isSelected = false,
    this.width,
  }) : assert(title != null || child != null,
            'Either title or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      margin: margin ?? EdgeInsets.only(bottom: AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: hasBorder
            ? Border.all(color: theme.colorScheme.outline.withOpacity(0.1))
            : null,
        boxShadow: [
          // Soft ambient shadow
          // BoxShadow(
          //   color: theme.colorScheme.outline.withOpacity(0.03),
          //   blurRadius: 12,
          //   offset: const Offset(0, 4),
          //   spreadRadius: 0,
          // ),
          // // Sharper edge shadow
          // BoxShadow(
          //   color: theme.colorScheme.outline.withOpacity(0.08),
          //   blurRadius: 8,
          //   offset: const Offset(0, 2),
          //   spreadRadius: -2,
          // ),
          AppTheme.cardShadow,
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppTheme.spaceLG),
            child: child ?? _buildDefaultContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null || title != null || actions != null)
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: AppTheme.spaceSM),
              ],
              if (title != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              if (actions != null) ...actions!,
            ],
          ),
      ],
    );
  }
}

class ThesisStatusChip extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const ThesisStatusChip({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = backgroundColor ?? theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSM,
        vertical: AppTheme.spaceXS,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor ?? statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
