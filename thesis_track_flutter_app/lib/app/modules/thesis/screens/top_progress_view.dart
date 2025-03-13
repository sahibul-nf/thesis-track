import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class TopProgressView extends GetView<ThesisController> {
  const TopProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isLoadingTopProgress) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            strokeCap: StrokeCap.round,
          ),
        );
      }

      if (controller.topProgressTheses.isEmpty) {
        return EmptyStateWidget(
          title: 'No Top Progress Found',
          message:
              'It looks like there are no theses with top progress to display. Try filtering by year or refreshing the list.',
          icon: Iconsax.ranking_1,
          onAction: () => controller.getAllTheses(),
          actionLabel: 'Refresh',
          actionIcon: Iconsax.refresh,
          buttonSize: const Size(140, 48),
        );
      }

      return Column(
        children: [
          // Year Filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
            child: Row(
              children: [
                Text('Filter by Academic Year:',
                    style: theme.textTheme.titleSmall),
                const SizedBox(width: 10),
                Obx(() => DropdownButton<String>(
                      value: controller.selectedYear.isEmpty
                          ? null
                          : controller.selectedYear,
                      hint: const Text('All'),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('All'),
                        ),
                        ...controller.availableYears.map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year ?? 'All'),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          controller.getTopProgressTheses(value),
                    )),
              ],
            ),
          ),

          // Progress List
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.all(AppTheme.spaceLG),
                  itemCount: controller.topProgressTheses.length,
                  itemBuilder: (context, index) {
                    final thesis = controller.topProgressTheses[index];
                    final progress = thesis.thesisProgress?.totalProgress ?? 0;

                    final isCurrentUser =
                        AuthController.to.user?.id == thesis.student.id;
                    final highlight = isCurrentUser;

                    return ThesisCard(
                      onTap: () => context.go(
                        RouteLocation.toThesisDetail(thesis.id),
                        extra: thesis,
                      ),
                      backgroundColor: highlight
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : null,
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
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.spaceXS),
                                    Text(
                                      thesis.title,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
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
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.chipRadius),
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
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: AppTheme.spaceSM),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${thesis.progresses.length} ',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Sessions',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
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
                                        backgroundColor: theme
                                            .colorScheme.secondaryContainer,
                                        child: Text(
                                          thesis.student.name[0].toUpperCase(),
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: AppTheme.spaceSM),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            thesis.student.name,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${thesis.student.year}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
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
                                        backgroundColor: theme
                                            .colorScheme.surfaceContainerLow,
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
                )),
          ),
        ],
      );
    });
  }
}

Color _getRankColor(int index) {
  switch (index) {
    case 0:
      return Colors.amber; // Gold
    case 1:
      return Colors.blueGrey; // Silver
    case 2:
      return Colors.brown; // Bronze
    default:
      return Colors.grey;
  }
}
