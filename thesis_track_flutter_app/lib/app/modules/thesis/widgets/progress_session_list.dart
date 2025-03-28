import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/widgets/progress_item.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class ProgressSessionList extends StatefulWidget {
  const ProgressSessionList({
    super.key,
    required this.thesis,
  });
  final Thesis thesis;

  @override
  State<ProgressSessionList> createState() => _ProgressSessionListState();
}

class _ProgressSessionListState extends State<ProgressSessionList> {
  // Add filter state
  final _selectedFilter = 'All'.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = AuthController.to.user?.role;
    final currentUserId = AuthController.to.user?.id;

    return Obx(() {
      // sort by createdAt descending
      final progresses = widget.thesis.progresses;

      // Filter progresses if "Me" is selected and user is lecturer
      final filteredProgresses =
          _selectedFilter.value == 'Me' && userRole == UserRole.lecturer
              ? progresses.where((p) => p.reviewerId == currentUserId).toList()
              : progresses;

      return Stack(
        children: [
          // Empty State for Student
          if (progresses.isEmpty && userRole == UserRole.student)
            EmptyStateWidget(
              icon: Iconsax.task_square,
              title: 'Begin Your Progress Journey',
              message:
                  'Track your thesis development by adding your first progress milestone',
              onAction: () => context.go(
                RouteLocation.toProgressCreate(widget.thesis.id),
                extra: widget.thesis,
              ),
            ),

          // Empty State for Lecturer & Admin
          if (userRole != UserRole.student && progresses.isEmpty)
            const EmptyStateWidget(
              icon: Iconsax.task_square,
              title: 'Awaiting Progress Updates',
              message:
                  'The student has not submitted any progress milestones for this thesis yet',
            ),

          // Empty state for filtered progress
          if (progresses.isNotEmpty &&
              filteredProgresses.isEmpty &&
              _selectedFilter.value == 'Me')
            const EmptyStateWidget(
              icon: Iconsax.task_square,
              title: 'No Assigned Progress',
              message:
                  'There are no progress sessions assigned to you for review',
            ),

          // Progress List with Filter
          if (progresses.isNotEmpty)
            Column(
              children: [
                // Filter Chips
                if (userRole == UserRole.lecturer)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.spaceLG,
                      AppTheme.spaceLG,
                      AppTheme.spaceLG,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilterChip(
                          selected: _selectedFilter.value == 'All',
                          onSelected: (selected) {
                            if (selected) _selectedFilter.value = 'All';
                          },
                          label: const Text('All'),
                          showCheckmark: false,
                          // backgroundColor: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: AppTheme.spaceSM),
                        FilterChip(
                          selected: _selectedFilter.value == 'Me',
                          onSelected: (selected) {
                            if (selected) _selectedFilter.value = 'Me';
                          },
                          label: const Text('Assigned to Me'),
                          showCheckmark: false,
                          // backgroundColor: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),

                // Progress List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.spaceLG,
                      AppTheme.spaceMD,
                      AppTheme.spaceLG,
                      AppTheme.spaceMD + 80,
                    ),
                    itemCount:
                        filteredProgresses.length + 1, // +1 for info card
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppTheme.spaceSM),
                    itemBuilder: (context, index) {
                      // Show info card at the top
                      if (index == 0) {
                        return _buildInfoCard();
                      }

                      // Show progress items
                      final progress = filteredProgresses[index - 1];
                      return ProgressItem(
                        progress: progress,
                        index: filteredProgresses.length - index,
                      );
                    },
                  ),
                ),
              ],
            ),

          // FAB for adding new progress
          if (RoleGuard.canAddProgress())
            Positioned(
              right: AppTheme.spaceMD,
              bottom: AppTheme.spaceMD,
              child: FloatingActionButton(
                tooltip: 'Add New Progress',
                // backgroundColor: theme.colorScheme.primary,
                // foregroundColor: theme.colorScheme.onPrimary,
                onPressed: () => context.go(
                  RouteLocation.toProgressCreate(widget.thesis.id),
                  extra: widget.thesis,
                ),
                child: const Icon(Iconsax.add),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    final thesis = widget.thesis;
    final user = AuthController.to.user;
    final userRole = user?.role;
    final currentUserId = user?.id;

    var isMyThesis = thesis.student.id == currentUserId;
    if (!isMyThesis) {
      return const SizedBox.shrink();
    }

    if (userRole != UserRole.student) {
      return const SizedBox.shrink();
    }

    if (thesis.status != ThesisStatus.inProgress) {
      return const SizedBox.shrink();
    }

    // Kondisi untuk Final Defense
    if (thesis.isFinalExamReady) {
      final hasFinalDefenseExaminer = thesis.examiners.any((e) =>
          e.examinerType == ThesisLectureExaminerType.finalDefenseExaminer &&
          e.finalDefenseApprovedAt == null);
      if (!hasFinalDefenseExaminer) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child:
                const Text('Waiting for final defense examiner to be assigned'),
          ),
        );
      }

      // Daftar dosen yang terlibat dalam final defense
      final finalDefenseInvolved = [
        ...thesis.examiners.where((e) =>
            e.examinerType == ThesisLectureExaminerType.finalDefenseExaminer),
        ...thesis.supervisors
      ];

      // Dapatkan waktu final exam ready (waktu terakhir supervisor approve)
      final finalExamReadyTime = thesis.supervisors
          .map((s) => s.finalDefenseApprovedAt)
          .where((date) => date != null)
          .reduce((a, b) => a!.isAfter(b!) ? a : b);

      // Filter progress yang dibuat setelah thesis final exam ready
      final finalDefenseProgresses = thesis.progresses.where((progress) {
        // Cek apakah progress dibuat setelah thesis final exam ready
        return finalExamReadyTime != null &&
            progress.createdAt.isAfter(finalExamReadyTime);
      }).toList();

      // Cek apakah setiap dosen yang terlibat sudah memiliki progress di fase final
      final allHaveProgress = finalDefenseInvolved.every((lecturer) {
        return finalDefenseProgresses
            .any((progress) => progress.reviewer.id == lecturer.user.id);
      });

      // Jika semua dosen sudah memiliki progress, sembunyikan CTA
      if (allHaveProgress) {
        return const SizedBox.shrink();
      }

      // Hitung dosen yang belum memiliki progress
      final remainingCount = finalDefenseInvolved.where((lecturer) {
        return !finalDefenseProgresses
            .any((progress) => progress.reviewer.id == lecturer.user.id);
      }).length;

      return ThesisCard(
        padding: EdgeInsets.all(AppTheme.spaceMD),
        backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.medal_star,
                        color: theme.colorScheme.secondary,
                        size: 20,
                      ),
                      SizedBox(width: AppTheme.spaceSM),
                      Text(
                        'Ready for Final Defense',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spaceSM),
                  Text(
                    'Congratulations! Your thesis is ready for final defense. Add a new progress to document your final defense preparation and results.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              child: FilledButton.icon(
                onPressed: () => context.go(
                  RouteLocation.toProgressCreate(thesis.id),
                  extra: thesis,
                ),
                icon: const Icon(Iconsax.add),
                label: const Text('Create Final Defense Session'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(100, 44),
                  backgroundColor: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final proposalExaminers = thesis.examiners
        .takeWhile((e) =>
            e.examinerType == ThesisLectureExaminerType.proposalDefenseExaminer)
        .toList();

    // all progress assigned to the proposal examiner
    final proposalExaminerProgresses = thesis.progresses.where((p) =>
        proposalExaminers.any((e) => e.user.id == p.reviewer.id) &&
        p.status.value.toLowerCase() == 'reviewed');

    final hasReadyProposalDefenseSession =
        proposalExaminerProgresses.isNotEmpty;
    if (hasReadyProposalDefenseSession) {
      return const SizedBox.shrink();
    }

    // Kondisi untuk Proposal Defense
    if (thesis.isProposalReady) {
      final hasProposalDefenseExaminer = thesis.examiners.any((e) =>
          e.examinerType == ThesisLectureExaminerType.proposalDefenseExaminer);
      if (!hasProposalDefenseExaminer) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child: const Text(
                'Waiting for proposal defense examiner to be assigned'),
          ),
        );
      }

      return ThesisCard(
        padding: EdgeInsets.all(AppTheme.spaceMD),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.verify,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: AppTheme.spaceSM),
                      Text(
                        'Proposal Defense Ready',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spaceSM),
                  Text(
                    'Congratulations! Your thesis is now ready for proposal defense. Take the next step by documenting your defense preparation and outcomes.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              child: FilledButton.icon(
                onPressed: () => context.go(
                  RouteLocation.toProgressCreate(thesis.id),
                  extra: thesis,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(100, 44),
                ),
                icon: const Icon(Iconsax.add),
                label: const Text('Create Defense Session'),
              ),
            ),
          ],
        ),
      );
    }

    // Return SizedBox if no info card needed
    return const SizedBox.shrink();
  }
}
