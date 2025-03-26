import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';

class TopProgressListView extends StatelessWidget {
  const TopProgressListView({super.key, required this.theses});
  final List<Thesis> theses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await ThesisController.to.getAllTheses();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppTheme.spaceLG),
        itemCount: theses.length,
        itemBuilder: (context, index) {
          final thesis = theses[index];
          final progress = thesis.thesisProgress?.totalProgress ?? 0;

          final isCurrentUser = AuthController.to.user?.id == thesis.student.id;
          final highlight = isCurrentUser;

          return ThesisCard(
            onTap: () => context.go(
              RouteLocation.toThesisDetail(thesis.id),
              extra: thesis,
            ),
            backgroundColor:
                highlight ? theme.colorScheme.primary.withOpacity(0.2) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank & Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rank Badge
                    Container(
                      padding: EdgeInsets.all(AppTheme.spaceSM),
                      decoration: BoxDecoration(
                        color: _getRankColor(index).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _getRankColor(index),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spaceMD),
                    // Title & Research Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            thesis.researchField,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppTheme.spaceXS),
                          Text(
                            thesis.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress Percentage
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSM,
                        vertical: AppTheme.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppTheme.chipRadius),
                      ),
                      child: Text(
                        '${progress.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spaceSM),

                // Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Last updated ${DateFormat('dd MMM yyyy').format(thesis.updatedAt)}  •',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: AppTheme.spaceSM),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${thesis.progresses.length} ',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sessions',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spaceMD),

                        // Student Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              child: Text(
                                thesis.student.name[0].toUpperCase(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            SizedBox(width: AppTheme.spaceSM),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thesis.student.name,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${thesis.student.year}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Progress Circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (progress < 100)
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: progress / 100,
                              strokeWidth: 16,
                              strokeCap: StrokeCap.round,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerLow,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        if (progress == 100)
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: theme.colorScheme.surface,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Color _getRankColor(int index) {
  return switch (index) {
    0 => Colors.amber, // Gold
    1 => Colors.blueGrey, // Silver
    2 => Colors.brown, // Bronze
    _ => Colors.grey,
  };
}
