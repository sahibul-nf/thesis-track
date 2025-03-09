import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/admin_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/widgets/metric_card.dart';
import 'package:thesis_track_flutter_app/app/modules/home/widgets/top_progress_card.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeAdminView extends StatelessWidget {
  const HomeAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thesisC = ThesisController.to;
    final adminC = AdminController.to;

    return Padding(
      padding: EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Metrics Row
          Obx(() {
            final totalUsers = adminC.totalUsers;
            final totalStudents = adminC.totalStudents;
            final totalLecturers = adminC.totalLecturers;
            final totalCompletedTheses = adminC.totalCompletedTheses;
            final totalOnTrackTheses = adminC.totalOnTrackTheses;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppTheme.spaceLG,
              children: [
                // Total Users
                Expanded(
                  child: MetricCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    detail: Column(
                      children: [
                        InkWell(
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spaceXS),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.buttonRadius),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(AppTheme.spaceXS),
                                      decoration: BoxDecoration(
                                        color: UserRole.student.color
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.buttonRadius),
                                      ),
                                      child: Icon(
                                        Iconsax.user,
                                        size: 16,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spaceSM),
                                    Text(
                                      'Students',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  totalStudents.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        InkWell(
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spaceXS),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.buttonRadius),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(AppTheme.spaceXS),
                                      decoration: BoxDecoration(
                                        color: UserRole.lecturer.color
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.buttonRadius),
                                      ),
                                      child: Icon(
                                        Iconsax.teacher,
                                        size: 16,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spaceSM),
                                    Text(
                                      'Lecturers',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  totalLecturers.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Completed Theses
                Expanded(
                  child: MetricCard(
                    title: 'Completed Theses',
                    value: totalCompletedTheses.toString(),
                    detail: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Recent Completed Theses List
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              adminC.recentCompletedTheses.take(2).length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppTheme.spaceXS),
                          itemBuilder: (context, index) {
                            return InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.buttonRadius),
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceXS,
                                  vertical: AppTheme.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.buttonRadius,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      child: Text(
                                        adminC.recentCompletedTheses[index]
                                            .student.name[0],
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spaceSM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            adminC.recentCompletedTheses[index]
                                                .title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          // Created format (12 hours ago)
                                          Text(
                                            timeago.format(adminC
                                                .recentCompletedTheses[index]
                                                .completionDate!),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // On Track Theses
                Expanded(
                  child: MetricCard(
                    title: 'On Track Theses',
                    value: totalOnTrackTheses.toString(),
                    detail: Column(
                      children: [
                        // Recent Completed Theses List
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: adminC.recentOnTrackTheses.take(2).length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppTheme.spaceXS),
                          itemBuilder: (context, index) {
                            return InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.buttonRadius),
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceXS,
                                  vertical: AppTheme.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.buttonRadius,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // CircleAvatar(
                                    //   radius: 14,
                                    //   backgroundColor:
                                    //       theme.colorScheme.primaryContainer,
                                    //   child: Text(
                                    //     adminC.recentOnTrackTheses[index]
                                    //         .student.name[0],
                                    //     style: theme.textTheme.labelSmall
                                    //         ?.copyWith(
                                    //       color: theme
                                    //           .colorScheme.onPrimaryContainer,
                                    //       fontWeight: FontWeight.w600,
                                    //     ),
                                    //   ),
                                    // ),
                                    // SizedBox(width: AppTheme.spaceSM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            adminC.recentOnTrackTheses[index]
                                                .title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          // Updated format (12 hours ago)
                                          Text(
                                            timeago.format(adminC
                                                .recentOnTrackTheses[index]
                                                .updatedAt),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spaceSM),
                                    // Status Chip
                                    Container(
                                      height: 20,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppTheme.spaceSM,
                                        // vertical: AppTheme.spaceXS,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.buttonRadius),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        adminC.recentOnTrackTheses[index].status
                                            .name,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          fontSize: 10,
                                          color: theme.colorScheme.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: TopProgressCard(
                    status: FeatureStatus.beta,
                  ),
                ),
              ],
            );
          }),
          // Recent Activities Section
          SizedBox(height: AppTheme.spaceMD),
          ThesisCard(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.spaceSM),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.chipRadius),
                          ),
                          child: Icon(
                            Iconsax.activity,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: AppTheme.spaceMD),
                        Text(
                          'Recent Activities',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => context.go('/thesis'),
                      icon: const Icon(
                        Iconsax.arrow_right_3,
                        size: 16,
                      ),
                      iconAlignment: IconAlignment.end,
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                        iconColor: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spaceMD),

                // Activity Timeline
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adminC.recentOnTrackTheses.take(5).length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: AppTheme.spaceSM),
                  itemBuilder: (context, index) {
                    final thesis = adminC.recentOnTrackTheses[index];
                    return InkWell(
                      onTap: () => context.go('/thesis/${thesis.id}'),
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonRadius),
                      child: Container(
                        padding: EdgeInsets.all(AppTheme.spaceMD),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Activity Icon
                            Container(
                              padding: EdgeInsets.all(AppTheme.spaceSM),
                              decoration: BoxDecoration(
                                color: _getActivityColor(thesis.status.name)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getActivityIcon(thesis.status.name),
                                size: 18,
                                color: _getActivityColor(thesis.status.name),
                              ),
                            ),
                            SizedBox(width: AppTheme.spaceMD),

                            // Activity Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        thesis.student.name,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        ' • ',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        thesis.status.name,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: _getActivityColor(
                                              thesis.status.name),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    thesis.title,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Timestamp
                            Text(
                              timeago.format(thesis.updatedAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Quick Stats Grid
          SizedBox(height: AppTheme.spaceMD),
          Row(
            spacing: AppTheme.spaceLG,
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Iconsax.timer_1,
                  title: 'Avg. Completion',
                  value: '${adminC.avgCompletionTime} months',
                  trend: '+2.1%',
                  trendUp: true,
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Iconsax.teacher,
                  title: 'Active Supervisors',
                  value: '${adminC.totalLecturers}',
                  trend: '+5.8%',
                  trendUp: true,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Iconsax.task_square,
                  title: 'Success Rate',
                  value: '92%',
                  trend: '+12.3%',
                  trendUp: true,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildQuickStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool trendUp,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return ThesisCard(
      padding: EdgeInsets.all(AppTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spaceSM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.chipRadius),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTheme.spaceSM),
          Tooltip(
            message: 'Trend compared to last month',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: trendUp
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendUp ? Iconsax.arrow_up_1 : Iconsax.arrow_down_1,
                    size: 12,
                    color: trendUp
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: trendUp
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successColor;
      case 'in progress':
        return AppTheme.primaryColor;
      case 'proposed':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getActivityIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Iconsax.tick_circle;
      case 'in progress':
        return Iconsax.timer_1;
      case 'proposed':
        return Iconsax.document_upload;
      default:
        return Iconsax.document_text;
    }
  }
}
