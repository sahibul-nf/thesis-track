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
  }) : assert(title != null || child != null,
            'Either title or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: margin ?? EdgeInsets.all(AppTheme.spaceMD),
      elevation: elevation ?? (isSelected ? 4 : 1),
      color: backgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: hasBorder
            ? BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.all(AppTheme.spaceMD),
          child: child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        SizedBox(width: AppTheme.spaceMD),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: AppTheme.spaceXS),
                              Text(
                                subtitle!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (actions != null) ...[
                        SizedBox(width: AppTheme.spaceSM),
                        ...actions!,
                      ],
                    ],
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class ThesisStatusChip extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const ThesisStatusChip({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = backgroundColor ?? AppTheme.getStatusColor(status);

    return Container(
      height: height ?? 28,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMD,
            vertical: AppTheme.spaceXS,
          ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor ?? statusColor,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
