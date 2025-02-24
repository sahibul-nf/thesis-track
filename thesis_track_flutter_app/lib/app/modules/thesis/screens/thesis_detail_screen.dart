import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Progress;
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/button.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/loading.dart';

class ThesisDetailScreen extends StatefulWidget {
  const ThesisDetailScreen({
    super.key,
    required this.thesisId,
  });

  final String thesisId;

  @override
  State<ThesisDetailScreen> createState() => _ThesisDetailScreenState();
}

class _ThesisDetailScreenState extends State<ThesisDetailScreen> {
  final _thesisController = Get.find<ThesisController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadThesis();
    if (RoleGuard.canAssignSupervisor()) {
      _loadLecturers();
    }
  }

  Future<void> _loadThesis() async {
    await _thesisController.getThesisById(widget.thesisId);
  }

  Future<void> _loadLecturers() async {
    await _thesisController.getLecturers();
  }

  Future<void> _assignSupervisor(User lecturer) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Supervisor'),
        content: Text(
          'Are you sure you want to assign ${lecturer.name} as supervisor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final errorMessage = await _thesisController.assignSupervisor(
      widget.thesisId,
      lecturer.id,
    );

    if (errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lecturer.name} has been assigned as supervisor'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await _loadThesis();
    }
  }

  Future<void> _assignExaminer(User lecturer) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Examiner'),
        content: Text(
          'Are you sure you want to assign ${lecturer.name} as examiner?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final errorMessage = await _thesisController.assignExaminer(
      widget.thesisId,
      lecturer.id,
    );

    if (errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lecturer.name} has been assigned as examiner'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await _loadThesis();
    }
  }

  Future<void> _showAssignLecturerDialog({
    required String title,
    required String role,
    required Function(User) onAssign,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign $title'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (_thesisController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final lecturers = _thesisController.lecturers;
            if (lecturers.isEmpty) {
              return const Center(
                child: Text('No lecturers available'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: lecturers.length,
              itemBuilder: (context, index) {
                final lecturer = lecturers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      lecturer.name[0].toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                  title: Text(lecturer.name),
                  subtitle: Text(lecturer.department),
                  onTap: () {
                    Navigator.pop(context);
                    onAssign(lecturer);
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveThesis() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Thesis'),
        content: const Text('Are you sure you want to approve this thesis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _thesisController.approveThesis(widget.thesisId);
      await _loadThesis();
    }
  }

  Future<void> _markAsCompleted() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text(
            'Are you sure you want to mark this thesis as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _thesisController.markAsCompleted(widget.thesisId);
      await _loadThesis();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Thesis Details',
      ),
      body: PageLayout(
        compactLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
        mediumLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
        expandedLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
      ),
      floatingActionButton: Obx(() {
        final thesis = _thesisController.selectedThesis;
        if (thesis == null) return const SizedBox();

        // Only student can add progress
        if (_authController.user?.id == thesis.student.id &&
            thesis.status != 'completed') {
          return ThesisFloatingActionButton(
            icon: Icons.add,
            label: 'Add Progress',
            extended: true,
            onPressed: () => context.go('/progress/${thesis.id}/create'),
          );
        }

        return const SizedBox();
      }),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (_thesisController.isLoading) {
        return const LoadingWidget();
      }

      final thesis = _thesisController.selectedThesis;
      if (thesis == null) {
        return const EmptyStateWidget(
          message: 'Thesis not found',
          icon: Iconsax.book_1,
        );
      }

      return RefreshIndicator(
        onRefresh: _loadThesis,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spaceMD),
          children: [
            _buildThesisHeader(thesis),
            SizedBox(height: AppTheme.spaceMD),
            _buildThesisDetails(thesis),
            SizedBox(height: AppTheme.spaceMD),
            _buildSupervisorsCard(thesis),
            SizedBox(height: AppTheme.spaceMD),
            _buildExaminersCard(thesis),
            SizedBox(height: AppTheme.spaceMD),
            _buildProgressSection(thesis),
            SizedBox(height: AppTheme.spaceMD),
            _buildDocumentsSection(thesis),
          ],
        ),
      );
    });
  }

  Widget _buildThesisHeader(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thesis.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spaceXS),
                    Text(
                      'By ${thesis.student.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spaceMD),
              ThesisStatusChip(status: thesis.status),
            ],
          ),
          if (RoleGuard.canApproveThesis() &&
              thesis.status.toLowerCase() == 'proposed') ...[
            SizedBox(height: AppTheme.spaceMD),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _approveThesis,
                    icon: const Icon(Iconsax.tick_circle),
                    label: const Text('Approve Thesis'),
                  ),
                ),
              ],
            ),
          ],
          if (RoleGuard.canMarkAsCompleted() &&
              thesis.status.toLowerCase() == 'in progress') ...[
            SizedBox(height: AppTheme.spaceMD),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _markAsCompleted,
                    icon: const Icon(Iconsax.tick_circle),
                    label: const Text('Mark as Completed'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThesisDetails(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abstract',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spaceSM),
          Text(
            thesis.abstract,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            'Research Field',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spaceSM),
          Text(
            thesis.researchField,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            'Submission Date',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spaceSM),
          Text(
            thesis.submissionDate.toString(),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorsCard(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.teacher,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: AppTheme.spaceSM),
              Text(
                'Supervisors',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          ...thesis.supervisors.map((supervisor) => _buildUserTile(supervisor)),
        ],
      ),
    );
  }

  Widget _buildExaminersCard(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.user_tick,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: AppTheme.spaceSM),
              Text(
                'Examiners',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          if (thesis.examiners.isEmpty)
            Text(
              'No examiners assigned yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...thesis.examiners.map((examiner) => _buildUserTile(examiner)),
        ],
      ),
    );
  }

  Widget _buildUserTile(User user) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.user,
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
                  user.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.department,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.task_square,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: AppTheme.spaceSM),
              Text(
                'Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (RoleGuard.canAddProgress() &&
                  thesis.status.toLowerCase() == 'in progress')
                TextButton.icon(
                  onPressed: () =>
                      context.go('/progress/thesis/${thesis.id}/create'),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Progress'),
                ),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          if (thesis.progresses.isEmpty)
            Text(
              'No progress records yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: thesis.progresses
                  .map((progress) => _buildProgressTile(progress))
                  .toList(),
            ),
          SizedBox(height: AppTheme.spaceSM),
          if (thesis.progresses.isNotEmpty)
            Center(
              child: TextButton(
                onPressed: () => context.go('/progress/thesis/${thesis.id}'),
                child: const Text('View All Progress'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTile(Progress progress) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go('/progress/${progress.id}/detail'),
      child: Padding(
        padding: EdgeInsets.only(bottom: AppTheme.spaceMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppTheme.spaceXS),
                  Row(
                    children: [
                      Text(
                        'Reviewed by ${progress.reviewer.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      ThesisStatusChip(
                        status: progress.status,
                        height: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.document,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: AppTheme.spaceSM),
              Text(
                'Documents',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (RoleGuard.canUploadDocuments() &&
                  thesis.status.toLowerCase() == 'in progress')
                TextButton.icon(
                  onPressed: () => context.go('/thesis/${thesis.id}/documents'),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Upload Document'),
                ),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          if (thesis.draftDocumentUrl == null &&
              thesis.finalDocumentUrl == null)
            Text(
              'No documents uploaded yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            if (thesis.draftDocumentUrl != null)
              _buildDocumentTile(
                'Draft Document',
                thesis.draftDocumentUrl!,
                Iconsax.document_normal,
              ),
            if (thesis.finalDocumentUrl != null)
              _buildDocumentTile(
                'Final Document',
                thesis.finalDocumentUrl!,
                Iconsax.document_text,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
    String title,
    String url,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final fileName = url.split('/').last;

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
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
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fileName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement document download
            },
            icon: const Icon(Iconsax.document_download),
          ),
        ],
      ),
    );
  }
}
