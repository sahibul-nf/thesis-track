import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/modules/home/widgets/top_progress_card.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/metric_card.dart';

class HomeStudentView extends StatelessWidget {
  const HomeStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    final thesisController = Get.find<ThesisController>();
    final theme = Theme.of(context);

    return Obx(() {
      final theses = thesisController.myTheses;
      if (theses.isEmpty && !thesisController.isLoading) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          width: MediaQuery.sizeOf(context).width,
          child: Center(
            child: EmptyStateWidget(
              title: 'Start Your Research Journey',
              message:
                  'Begin your academic journey by submitting your first thesis proposal',
              icon: Iconsax.document_text,
              actionLabel: 'Create New Thesis',
              buttonSize: Size(120, AppTheme.buttonMedium),
              onAction: () => context.go(RouteLocation.toCreateThesis),
            ),
          ),
        );
      }

      final thesis = theses.firstOrNull;
      final timeSpent = thesis?.status == ThesisStatus.completed
          ? thesis?.completionDate?.difference(thesis.submissionDate).inDays ??
              0
          : DateTime.now()
              .difference(thesis?.submissionDate ?? DateTime.now())
              .inDays;

      final thesisProgress = thesisController.thesisProgress;
      final totalPercentageProgress = thesisProgress?.totalProgress;
      final initialPhase = thesisProgress?.details.initialPhase;
      final proposalPhase = thesisProgress?.details.proposalPhase;
      final researchPhase = thesisProgress?.details.researchPhase;
      final finalPhase = thesisProgress?.details.finalPhase;

      final progresses = thesis?.progresses ?? [];

      return RefreshIndicator(
        onRefresh: () async {
          await thesisController.getMyTheses();
        },
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spaceLG),
          children: [
            // Top Metrics Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppTheme.spaceLG,
              children: [
                // Overall Progress
                Expanded(
                  child: MetricCard(
                    title: 'Overall Progress',
                    value:
                        '${(totalPercentageProgress?.toStringAsFixed(0) ?? 0)}%',
                    status: FeatureStatus.beta,
                    detail: SizedBox(
                      height: 78,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress phase so far ...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPhaseProgress(
                                context,
                                'Initial',
                                initialPhase ?? 0,
                                weight:
                                    15, // InitialSubmissionWeight + InProgressWeight
                                isCompleted: initialPhase == 15,
                              ),
                              _buildPhaseProgress(
                                context,
                                'Proposal',
                                proposalPhase ?? 0,
                                weight:
                                    35, // ProposalProgressWeight + ProposalApprovalWeight
                                isCompleted: proposalPhase == 35,
                              ),
                              _buildPhaseProgress(
                                context,
                                'Research',
                                researchPhase ?? 0,
                                weight: 15, // ResearchProgressWeight
                                isCompleted: researchPhase == 15,
                              ),
                              _buildPhaseProgress(
                                context,
                                'Final',
                                finalPhase ?? 0,
                                weight:
                                    35, // FinalProgressWeight + FinalApprovalWeight + CompletionWeight
                                isCompleted: finalPhase == 35,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Days Active
                Expanded(
                  child: MetricCard(
                    title: 'Total Time Spent',
                    value: '$timeSpent Days',
                  ),
                ),
                // Total Progress
                Expanded(
                  child: MetricCard(
                    title: 'Total Progress',
                    value: '${progresses.length} session',
                  ),
                ),
                // Current Phase & Other Progress
                const Expanded(
                  child: TopProgressCard(
                    status: FeatureStatus.beta,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spaceMD),

            // Recent Progress Section
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
                              Iconsax.task_square,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: AppTheme.spaceMD),
                          Text(
                            'Recent Progress',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.go(
                          RouteLocation.toProgressList(thesis!.id),
                          extra: thesis,
                        ),
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
                  if (progresses.isEmpty)
                    EmptyStateWidget(
                      title: 'No progress yet',
                      message:
                          'Start your progress journey by submitting your first progress',
                      icon: Iconsax.document_text,
                      onAction: () => context.go(
                        RouteLocation.toProgressCreate(thesis!.id),
                        extra: thesis,
                      ),
                      buttonSize: Size(120, AppTheme.buttonSmall),
                      actionLabel: 'Add Progress',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: progresses.take(5).length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: AppTheme.spaceSM),
                      itemBuilder: (context, index) =>
                          _buildProgressTile(context, progresses[index]),
                    ),
                ],
              ),
            ),
          ],
        ).asSkeleton(
          enabled: thesisController.isLoading,
        ),
      );
    });
  }

  Widget _buildProgressTile(BuildContext context, ProgressModel progress) {
    final theme = Theme.of(context);
    final formattedDate = progress.achievementDate.toString();

    return InkWell(
      onTap: () => context.go('/progress/${progress.id}/detail'),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.document_text,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.progressDescription,
                    style: theme.textTheme.titleSmall?.copyWith(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Reviewed by ${progress.reviewer.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Created at
                      Text(
                        ' • ${timeago.format(progress.achievementDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              return ThesisStatusChip(
                status: progress.status.value,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseProgress(
      BuildContext context, String phase, double progress,
      {required double weight, bool isCompleted = false}) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (!isCompleted)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress / weight,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: isCompleted
                      ? AppTheme.successColor
                      : theme.colorScheme.primary,
                ),
              ),
            if (isCompleted)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successColor
                      : theme.colorScheme.primary,
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
        SizedBox(height: AppTheme.spaceXS),
        // phase
        Text(
          phase,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
