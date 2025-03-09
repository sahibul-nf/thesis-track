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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progresses = widget.thesis.progresses;
    final userRole = AuthController.to.user?.role;

    return Obx(() {
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

          // Progress List
          if (progresses.isNotEmpty)
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppTheme.spaceLG,
                AppTheme.spaceLG,
                AppTheme.spaceLG,
                AppTheme.spaceMD + 80,
              ),
              itemCount: progresses.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppTheme.spaceSM),
              itemBuilder: (context, index) {
                final progress = progresses[index];
                return ProgressItem(
                  progress: progress,
                  index: index,
                );
              },
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
}
