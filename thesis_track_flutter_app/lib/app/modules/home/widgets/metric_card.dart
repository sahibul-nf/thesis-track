import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';

enum FeatureStatus {
  newest(color: Colors.blue, name: 'New'),
  beta(color: Colors.orange, name: 'Beta');

  const FeatureStatus({required this.color, required this.name});

  final Color color;
  final String name;
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.detail,
    this.status,
  });

  final String title;
  final String value;
  final Widget? detail;
  final FeatureStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 208,
      child: ThesisCard(
        padding: EdgeInsets.all(AppTheme.spaceMD),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppTheme.spaceSM),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // // Progress Bar
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: SizedBox(
                //     width: 50,
                //     height: 50,
                //     child: CircularProgressIndicator(
                //       value: 0.5,
                //       strokeWidth: 12,
                //       strokeCap: StrokeCap.round,
                //       backgroundColor: theme.colorScheme.surfaceContainerHighest,
                //       color: theme.colorScheme.primary,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 12),
                DottedLine(
                  dashRadius: 10,
                  dashLength: 5,
                  dashGapLength: 10,
                  lineThickness: 1.2,
                  dashColor: theme.colorScheme.outline.withOpacity(0.12),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 10),
                  detail!,
                ],
                if (detail == null) ...[
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildEmptyState(
                      context,
                      message: 'No data available',
                    ),
                  ),
                ],
              ],
            ),
            // Chip for (widget status [new, beta, etc])
            if (status != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  height: 20,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSM,
                    // vertical: AppTheme.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    status!.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget for Metric Card
  Widget _buildEmptyState(BuildContext context, {required String message}) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
      ),
    );
  }
}
