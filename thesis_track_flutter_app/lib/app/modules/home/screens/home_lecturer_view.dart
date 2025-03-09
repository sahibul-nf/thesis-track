import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/lecturer_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';

import '../widgets/metric_card.dart';

class HomeLecturerView extends StatelessWidget {
  const HomeLecturerView({super.key});

  @override
  Widget build(BuildContext context) {
    final thesisController = Get.find<ThesisController>();
    final lecturerC = LecturerController.to;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.spaceLG),
      child: Obx(() {
        final theses = thesisController.myTheses;
        final activeTheses =
            theses.where((t) => t.status != ThesisStatus.completed).length;
        final completedTheses =
            theses.where((t) => t.status == ThesisStatus.completed).length;

        final coActiveCount = lecturerC.recentCoSupervisions
            .where((t) => t.status != ThesisStatus.completed)
            .length;
        final coCompletedCount = lecturerC.recentCoSupervisions
            .where((t) => t.status == ThesisStatus.completed)
            .length;

        final scheduledExams = lecturerC.recentExaminations
            .where((t) => t.status == ThesisStatus.inProgress)
            .length;
        final completedExams = lecturerC.recentExaminations
            .where((t) => t.status == ThesisStatus.completed)
            .length;

        final pendingReviews = lecturerC.recentProgressReviews
            .where((t) => t.status == 'pending')
            .length;
        final pendingApprovals = lecturerC.recentProgressReviews
            .where((t) => t.status == 'pending')
            .length;

        return ListView(
          children: [
            // Top Metrics Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppTheme.spaceLG,
              children: [
                // Main Supervision
                Expanded(
                  child: MetricCard(
                    title: 'Main Supervision',
                    value: lecturerC.recentSupervisions.length.toString(),
                    detail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppTheme.spaceXS),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.chipRadius),
                              ),
                              child: Icon(
                                Iconsax.teacher,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: AppTheme.spaceSM),
                            Expanded(
                              child: Text(
                                'As Main Supervisor',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusIndicator(
                              'Active',
                              activeTheses,
                              AppTheme.primaryColor,
                              context,
                            ),
                            _buildStatusIndicator(
                              'Completed',
                              completedTheses,
                              AppTheme.successColor,
                              context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Co-Supervision
                Expanded(
                  child: MetricCard(
                    title: 'Co-Supervision',
                    value: lecturerC.recentCoSupervisions.length.toString(),
                    detail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppTheme.spaceXS),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.chipRadius),
                              ),
                              child: Icon(
                                Iconsax.people,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            SizedBox(width: AppTheme.spaceSM),
                            Expanded(
                              child: Text(
                                'As Co-Supervisor',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusIndicator(
                              'Active',
                              coActiveCount,
                              theme.colorScheme.secondary,
                              context,
                            ),
                            _buildStatusIndicator(
                              'Completed',
                              coCompletedCount,
                              AppTheme.successColor,
                              context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Examiner Role
                Expanded(
                  child: MetricCard(
                    title: 'Examiner Role',
                    value: lecturerC.recentExaminations.length.toString(),
                    detail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppTheme.spaceXS),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.tertiary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.chipRadius),
                              ),
                              child: Icon(
                                Iconsax.verify,
                                size: 16,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                            SizedBox(width: AppTheme.spaceSM),
                            Expanded(
                              child: Text(
                                'As Examiner',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusIndicator(
                              'Scheduled',
                              scheduledExams,
                              theme.colorScheme.tertiary,
                              context,
                            ),
                            _buildStatusIndicator(
                              'Completed',
                              completedExams,
                              AppTheme.successColor,
                              context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Pending Actions
                Expanded(
                  child: MetricCard(
                    title: 'Pending Actions',
                    value: _getPendingActionsCount(theses).toString(),
                    detail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppTheme.spaceXS),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.chipRadius),
                              ),
                              child: const Icon(
                                Iconsax.timer,
                                size: 16,
                                color: AppTheme.warningColor,
                              ),
                            ),
                            SizedBox(width: AppTheme.spaceSM),
                            Expanded(
                              child: Text(
                                'Need Attention',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusIndicator(
                              'Reviews',
                              pendingReviews,
                              AppTheme.warningColor,
                              context,
                            ),
                            _buildStatusIndicator(
                              'Approvals',
                              pendingApprovals,
                              AppTheme.warningColor,
                              context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.spaceLG),

            // Recent Supervisions
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
                              Iconsax.teacher,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: AppTheme.spaceMD),
                          Text(
                            'Recent Supervisions',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.go(RouteLocation.myThesis),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                        ),
                        label: const Text('View All'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                          iconColor: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spaceMD),

                  // Recent Theses List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: theses.take(5).length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppTheme.spaceSM),
                    itemBuilder: (context, index) {
                      final thesis = theses[index];
                      return InkWell(
                        onTap: () => context.go(
                          RouteLocation.toThesisDetail(thesis.id),
                          extra: thesis,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.cardRadius),
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spaceMD),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppTheme.spaceSM),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(thesis.status)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getStatusIcon(thesis.status),
                                  size: 20,
                                  color: _getStatusColor(thesis.status),
                                ),
                              ),
                              SizedBox(width: AppTheme.spaceMD),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      thesis.student.name,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      thesis.title,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              ThesisStatusChip(
                                status: thesis.status.name,
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
          ],
        );
      }),
    );
  }

  Color _getStatusColor(ThesisStatus status) {
    return switch (status) {
      ThesisStatus.completed => AppTheme.successColor,
      ThesisStatus.inProgress => AppTheme.primaryColor,
      ThesisStatus.pending => AppTheme.warningColor,
      _ => AppTheme.primaryColor,
    };
  }

  IconData _getStatusIcon(ThesisStatus status) {
    return switch (status) {
      ThesisStatus.completed => Iconsax.tick_circle,
      ThesisStatus.inProgress => Iconsax.timer_1,
      ThesisStatus.pending => Iconsax.document_upload,
      _ => Iconsax.document_text,
    };
  }

  int _getPendingActionsCount(List<Thesis> theses) {
    final userId = AuthController.to.user?.id;
    return theses.where((thesis) {
      // Count theses where:
      // 1. Pending progress reviews
      bool pendingProgress = thesis.progresses
          .where((p) => p.status == 'pending' && p.reviewer.id == userId)
          .isNotEmpty;

      return pendingProgress;
    }).length;
  }

  Widget _buildStatusIndicator(
      String label, int count, Color color, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
