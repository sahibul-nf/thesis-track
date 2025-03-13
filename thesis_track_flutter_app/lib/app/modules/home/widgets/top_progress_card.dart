import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/widgets/metric_card.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';

class TopProgressCard extends StatelessWidget {
  const TopProgressCard({super.key, this.status});
  final FeatureStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thesisC = ThesisController.to;
    final user = AuthController.to.user;

    final userRole = user?.role;
    final isStudent = userRole == UserRole.student;

    return Obx(() {
      final topProgressThesesPreview = isStudent
          ? thesisC.topProgressTheses.take(2).toList()
          : thesisC.topProgressTheses.take(3).toList();

      return GestureDetector(
        onTap: () => context.go(RouteLocation.topProgress),
        child: SizedBox(
          height: 208,
          child: ThesisCard(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            // fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go(RouteLocation.topProgress),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'View All',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isStudent ? AppTheme.spaceSM : AppTheme.spaceMD,
                    ),
                    if (isStudent) ...[
                      Row(
                        spacing: 10,
                        children: [
                          Text(
                            '#${thesisC.myTopProgressPosition + 1}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'of ${thesisC.topProgressThesesCount} students',
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
                    ],
                    // Other users thesis progress
                    ListView.separated(
                      itemCount: topProgressThesesPreview.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: AppTheme.spaceXS),
                      itemBuilder: (context, index) {
                        final thesis = topProgressThesesPreview[index];
                        final isCurrentUser = thesis.student.id == user?.id;
                        bool highlight = isCurrentUser;
                        if (!isStudent) {
                          highlight = index == 0;
                        }

                        return _buildThesisProgressTile(
                          context,
                          name: thesis.student.name,
                          title: thesis.title,
                          progress: thesis.thesisProgress?.totalProgress ?? 0,
                          rank: (index + 1).toString(),
                          highlight: highlight,
                          onTap: () => context.go(
                            RouteLocation.toThesisDetail(thesis.id),
                            extra: thesis,
                          ),
                        );
                      },
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
                        borderRadius:
                            BorderRadius.circular(AppTheme.buttonRadius),
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
        ),
      );
    });
  }

  Widget _buildThesisProgressTile(
    BuildContext context, {
    required String name,
    required String title,
    required double progress,
    required String rank,
    bool highlight = false,
    required void Function() onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spaceXS),
        decoration: BoxDecoration(
          color: highlight ? theme.colorScheme.surfaceBright : null,
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
                      color: highlight
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
                color: highlight
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
