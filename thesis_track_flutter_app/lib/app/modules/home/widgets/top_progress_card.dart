import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/modules/home/widgets/metric_card.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';

class TopProgressCard extends StatelessWidget {
  const TopProgressCard({super.key, this.status});
  final FeatureStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thesisController = ThesisController.to;

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
                  'Top Progress',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppTheme.spaceSM),
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      '#2',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'of 15 students',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
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
                const SizedBox(height: 10),
                // Other users thesis progress
                ListView.separated(
                  itemCount: thesisController.otherTheses.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: AppTheme.spaceXS),
                  itemBuilder: (context, index) => _buildThesisProgressTile(
                    context,
                    name: thesisController.otherTheses[index].student.name,
                    title: thesisController.otherTheses[index].title,
                    progress: 0,
                    rank: (index + 1).toString(),
                    isCurrentUser: index == 1,
                  ),
                ),
              ],
            ),
            // Chip for (widget status [new, beta, etc])
            if (status != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                  child: Text(
                    status?.name ?? '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
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

  Widget _buildThesisProgressTile(
    BuildContext context, {
    required String name,
    required String title,
    required double progress,
    required String rank,
    bool isCurrentUser = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      onTap: () => context.go('/thesis/detail/}'),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spaceXS),
        decoration: BoxDecoration(
          color: isCurrentUser ? theme.colorScheme.surfaceBright : null,
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        ),
        child: Row(
          children: [
            // Profile Circle
            SizedBox(
              width: 28,
              height: 28,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  name[0].toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppTheme.spaceSM),
            // Thesis Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // number of rank + name
                  Text(
                    '#$rank $name',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCurrentUser
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppTheme.spaceMD),
            // Progress Text
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCurrentUser
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
