import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/core/utils.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/admin_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/custom_menu_item.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/popup_menu.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';

class ThesisDetailHeader extends StatefulWidget {
  const ThesisDetailHeader({super.key, required this.thesis});
  final Thesis thesis;

  @override
  State<ThesisDetailHeader> createState() => _ThesisDetailHeaderState();
}

class _ThesisDetailHeaderState extends State<ThesisDetailHeader> {
  Future<void> _loadThesis() async {
    await ThesisController.to.getThesisById(widget.thesis.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Icon or Thesis Avatar
                    _buildResearchFieldIcon(
                      widget.thesis.researchField,
                    ),
                    SizedBox(width: AppTheme.spaceMD),
                    // Thesis Title
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.thesis.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppTheme.spaceSM),
                          Row(
                            children: [
                              Icon(
                                Iconsax.book_1,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: AppTheme.spaceXS),
                              Text(
                                widget.thesis.researchField,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              // Created At
                              Text(
                                ' • Created ${DateFormat('dd MMM yyyy').format(widget.thesis.createdAt)}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spaceSM),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceSM,
                              vertical: AppTheme.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.thesis.status.color.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.chipRadius),
                            ),
                            child: Text(
                              widget.thesis.status.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: widget.thesis.status.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spaceMD),
              // Refresh Button
              IconButton(
                onPressed: _loadThesis,
                tooltip: 'Refresh',
                icon: ThesisController.to.isLoadingMyThesis
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          strokeCap: StrokeCap.round,
                        ),
                      )
                    : const Icon(Iconsax.refresh),
              ),
              SizedBox(width: AppTheme.spaceXS),
              // Options Button
              PopupMenu(
                builder: (context, c, child) {
                  return IconButton(
                    tooltip: 'More actions',
                    onPressed: () {
                      var buttonPosition =
                          Offset(MediaQuery.of(context).size.width, 108);

                      c.open(
                        position: buttonPosition,
                      );
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(AppTheme.spaceSM),
                      fixedSize: const Size(24, 24),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.cardRadius),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.more_horiz),
                  );
                },
                menuChildren: [
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 240,
                      minWidth: 200,
                    ),
                    child: Column(
                      children: [
                        // Refresh Thesis
                        CustomMenuItem(
                          onTap: _loadThesis,
                          leading: const Icon(Iconsax.refresh, size: 18),
                          title: 'Refresh',
                        ),
                        // Edit Thesis
                        if (RoleGuard.canEditThesis(widget.thesis.studentId))
                          CustomMenuItem(
                            onTap: () {
                              MyToast.showComingSoonToast(context);
                            },
                            leading: const Icon(Iconsax.edit, size: 18),
                            title: 'Edit',
                          ),
                        if (RoleGuard.canAssignSupervisor(widget.thesis))
                          CustomMenuItem(
                            onTap: () {
                              _showAssignLecturerDialog(
                                title: 'Supervisor',
                                role: 'supervisor',
                                onAssign: _assignSupervisor,
                              );
                            },
                            leading: const Icon(Iconsax.teacher, size: 18),
                            title: 'Assign Supervisor',
                          ),

                        if (RoleGuard.canAssignProposalDefenseExaminer(
                            widget.thesis))
                          CustomMenuItem(
                            onTap: () {
                              _showAssignLecturerDialog(
                                title: 'Proposal Defense Examiner',
                                role: 'proposal defense examiner',
                                onAssign: (lecturer) => _assignExaminer(
                                    lecturer,
                                    ThesisLectureExaminerType
                                        .proposalDefenseExaminer),
                              );
                            },
                            leading: const Icon(Iconsax.verify, size: 18),
                            title: 'Assign Examiner for Proposal Defense',
                          ),

                        if (RoleGuard.canAssignFinalDefenseExaminer(
                            widget.thesis))
                          CustomMenuItem(
                            onTap: () {
                              _showAssignLecturerDialog(
                                title: 'Final Defense Examiner',
                                role: 'final defense examiner',
                                onAssign: (lecturer) => _assignExaminer(
                                    lecturer,
                                    ThesisLectureExaminerType
                                        .finalDefenseExaminer),
                              );
                            },
                            leading: const Icon(Iconsax.verify, size: 18),
                            title: 'Assign Examiner for Final Defense',
                          ),

                        if (RoleGuard.canApproveThesisForProposalDefense(
                                widget.thesis)
                            .value)
                          CustomMenuItem(
                            onTap: () {
                              MyToast.showComingSoonToast(context);
                            },
                            leading: const Icon(Iconsax.tick_circle, size: 18),
                            title: 'Approve Proposal Defense',
                          ),

                        if (RoleGuard.canApproveThesisForFinalDefense(
                            widget.thesis))
                          CustomMenuItem(
                            onTap: () {
                              MyToast.showComingSoonToast(context);
                            },
                            leading: const Icon(Iconsax.tick_circle, size: 18),
                            title: 'Approve Final Defense',
                          ),

                        if (RoleGuard.canAcceptThesisSubmission(widget.thesis))
                          CustomMenuItem(
                            onTap: _showAcceptThesisDialog,
                            leading: const Icon(Iconsax.tick_circle, size: 18),
                            title: 'Accept Submission',
                          ),

                        if (RoleGuard.canApproveThesisForFinalization(
                            widget.thesis))
                          CustomMenuItem(
                            onTap: _showApproveFinalizationDialog,
                            leading: const Icon(Iconsax.tick_circle, size: 18),
                            title: 'Finalize Thesis',
                          ),

                        if (RoleGuard.canMarkAsCompleted(widget.thesis))
                          CustomMenuItem(
                            onTap: _markAsCompleted,
                            leading: const Icon(Iconsax.task_square, size: 18),
                            title: 'Mark as Completed',
                          ),

                        // Delete Thesis
                        if (RoleGuard.canDeleteThesis(widget.thesis.studentId))
                          CustomMenuItem(
                            onTap: () {
                              MyToast.showComingSoonToast(context);
                            },
                            leading: const Icon(Iconsax.trash, size: 18),
                            title: 'Delete',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReadMoreText(
                "${widget.thesis.abstract.trim()} ",
                trimLines: 3,
                trimMode: TrimMode.Line,
                preDataText: "Abstract --",
                preDataTextStyle: theme.textTheme.titleMedium?.copyWith(
                  // color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                colorClickableText: theme.colorScheme.secondary,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          // Thesis Team
          _buildTeamWidget(widget.thesis),
          // Thesis actions based on role guard
          _buildThesisActions(widget.thesis),
        ],
      ),
    );
  }

  Widget _buildThesisActions(Thesis thesis) {
    final theme = Theme.of(context);
    final thesisC = ThesisController.to;

    return Obx(() {
      var canApproveProposalDefense =
          RoleGuard.canApproveThesisForProposalDefense(thesis).value;
      var canApproveFinalDefense =
          RoleGuard.canApproveThesisForFinalDefense(thesis);
      final canAssignSupervisor = RoleGuard.canAssignSupervisor(thesis);
      final canAssignProposalDefenseExaminer =
          RoleGuard.canAssignProposalDefenseExaminer(thesis);
      final canAssignFinalDefenseExaminer =
          RoleGuard.canAssignFinalDefenseExaminer(thesis);
      var canAccept = RoleGuard.canAcceptThesisSubmission(thesis);
      var canMarkAsCompleted = RoleGuard.canMarkAsCompleted(thesis);
      var canApproveFinalization =
          RoleGuard.canApproveThesisForFinalization(thesis);

      return Visibility(
        visible: canAccept ||
            canApproveProposalDefense ||
            canApproveFinalDefense ||
            canAssignProposalDefenseExaminer ||
            canAssignSupervisor ||
            canAssignFinalDefenseExaminer ||
            canMarkAsCompleted ||
            canApproveFinalization,
        child: Padding(
          padding: EdgeInsets.only(top: AppTheme.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  text:
                      'You have reached the requirment to do this actions below. ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Learn more',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spaceSM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: AppTheme.spaceSM,
                children: [
                  if (canAccept)
                    FilledButton(
                      onPressed: thesisC.isAssigningSupervisor
                          ? null
                          : () {
                              _showAcceptThesisDialog();
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: thesisC.isAssigningSupervisor
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Accept Submission'),
                    ),
                  if (canAssignSupervisor)
                    if (canAssignProposalDefenseExaminer)
                      FilledButton(
                        onPressed: thesisC.isAssigningSupervisor
                            ? null
                            : () {
                                _showAssignLecturerDialog(
                                  title: 'Supervisor',
                                  role: ThesisLectureRole.supervisor.name,
                                  onAssign: (lecturer) =>
                                      _assignSupervisor(lecturer),
                                );
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(100, 44),
                        ),
                        child: thesisC.isAssigningSupervisor
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  strokeCap: StrokeCap.round,
                                ),
                              )
                            : const Text('Assign Supervisor'),
                      ),
                  if (canAssignProposalDefenseExaminer)
                    FilledButton(
                      onPressed: thesisC.isAssigningExaminer
                          ? null
                          : () {
                              _showAssignLecturerDialog(
                                title: 'Examiner',
                                role: ThesisLectureExaminerType
                                    .proposalDefenseExaminer.name,
                                onAssign: (lecturer) => _assignExaminer(
                                  lecturer,
                                  ThesisLectureExaminerType
                                      .proposalDefenseExaminer,
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: thesisC.isAssigningExaminer
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Assign Examiner'),
                    ),
                  if (canAssignFinalDefenseExaminer)
                    FilledButton(
                      onPressed: thesisC.isAssigningExaminer
                          ? null
                          : () {
                              _showAssignLecturerDialog(
                                title: 'Examiner',
                                role: ThesisLectureExaminerType
                                    .finalDefenseExaminer.name,
                                onAssign: (lecturer) => _assignExaminer(
                                  lecturer,
                                  ThesisLectureExaminerType
                                      .finalDefenseExaminer,
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: thesisC.isAssigningExaminer
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Assign Final Defense Examiner'),
                    ),
                  if (canApproveProposalDefense)
                    FilledButton(
                      onPressed: thesisC.isApprovingForDefense
                          ? null
                          : () => _approveThesis('proposal defense'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: thesisC.isApprovingForDefense
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Approve Proposal Defense'),
                    ),
                  if (canApproveFinalDefense)
                    FilledButton(
                      onPressed: thesisC.isApprovingForDefense
                          ? null
                          : () => _approveThesis('final defense'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: thesisC.isApprovingForDefense
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Approve Final Defense'),
                    ),
                  if (canApproveFinalization)
                    FilledButton(
                      onPressed: thesisC.isFinalizingThesis
                          ? null
                          : () => _showApproveFinalizationDialog(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: thesisC.isFinalizingThesis
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Finalize Thesis'),
                    ),
                  if (canMarkAsCompleted)
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: const Text('Mark as Completed'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildResearchFieldIcon(String researchField) {
    final (icon, color) = Utils.getResearchFieldIconAndColor(researchField);

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: color,
      ),
    );
  }

  Future<void> _showAcceptThesisDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Submission'),
        content: const Text('Are you sure you want to accept this submission?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ThesisController.to.acceptThesis(
        widget.thesis.id,
        widget.thesis.supervisorId,
      );
    }
  }

  Future<void> _showApproveFinalizationDialog() async {
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Thesis Approval'),
        content: const Text('Are you sure you want to finalize this thesis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalize'),
          ),
        ],
      ),
    );

    if (confirmed == false || confirmed == null) return;

    String? err = await ThesisController.to.approveThesisForFinalization(
      widget.thesis.id,
    );

    if (err != null) {
      if (!mounted) return;
      MyToast.showShadcnUIToast(
        context,
        'Error',
        'Failed to finalize thesis: $err',
        isError: true,
      );
    }

    if (!mounted) return;
    MyToast.showShadcnUIToast(
      context,
      'Success',
      'Thesis successfully finalized',
      isError: false,
    );
  }

  void _showAssignReviewerDialog(ProgressModel progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Assign Reviewer',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a lecturer to review this progress session:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppTheme.spaceMD),
            // Add your lecturer selection dropdown or list here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Add your assign reviewer logic here
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamWidget(Thesis thesis) {
    final theme = Theme.of(context);

    var isPending = thesis.status == ThesisStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[
          InkWell(
            onTap: () => _showListOfMembersDialog(),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                sha.AvatarGroup.toLeft(
                  children: [
                    sha.Avatar(
                      initials: sha.Avatar.getInitials(thesis.student.name),
                      size: 24,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    ...thesis.supervisors.map((supervisor) => sha.Avatar(
                          initials:
                              sha.Avatar.getInitials(supervisor.user.name),
                          size: 24,
                          backgroundColor: theme.colorScheme.secondary,
                        )),
                    ...thesis.examiners.map((examiner) => sha.Avatar(
                          initials: sha.Avatar.getInitials(examiner.user.name),
                          size: 24,
                          backgroundColor: theme.colorScheme.primaryContainer,
                        )),
                  ],
                ),
                SizedBox(width: AppTheme.spaceSM),
                Text(
                  '${thesis.supervisors.length + thesis.examiners.length + 1} Members',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spaceLG),
        ],
        Text(
          isPending ? 'Will be managed by' : 'Managed by',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spaceSM),
        Row(
          children: [
            // Student Profile Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              padding: EdgeInsets.all(AppTheme.spaceSM),
              child: Row(
                children: [
                  sha.Avatar(
                    initials: sha.Avatar.getInitials(thesis.student.name),
                    size: 32,
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  SizedBox(width: AppTheme.spaceSM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thesis.student.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      sha.Button.text(
                        onPressed: () {},
                        style: const sha.ButtonStyle.ghost(
                          density: sha.ButtonDensity.compact,
                        ),
                        child: Text(
                          'Student',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppTheme.spaceLG)
                ],
              ),
            ),
            SizedBox(width: AppTheme.spaceSM),
            // Main Supervisor Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              padding: EdgeInsets.all(AppTheme.spaceSM),
              child: Row(
                children: [
                  sha.Avatar(
                    initials:
                        sha.Avatar.getInitials(thesis.mainSupervisor.name),
                    size: 32,
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                  SizedBox(width: AppTheme.spaceSM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thesis.mainSupervisor.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      sha.Button.text(
                        onPressed: () {},
                        style: const sha.ButtonStyle.ghost(
                          density: sha.ButtonDensity.compact,
                        ),
                        child: Text(
                          'Main Supervisor',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppTheme.spaceLG)
                ],
              ),
            ),
          ],
        ),
        if (thesis.finalizationApprovedExaminers.isNotEmpty) ...[
          SizedBox(height: AppTheme.spaceMD),
          Text(
            'Finalization Approved by ${thesis.finalizationApprovedExaminers.length} examiners',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spaceSM),
          Row(
            spacing: AppTheme.spaceSM,
            children: [
              ...thesis.finalizationApprovedExaminers.map((examiner) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  padding: EdgeInsets.all(AppTheme.spaceSM),
                  child: Row(
                    children: [
                      sha.Avatar(
                        initials: sha.Avatar.getInitials(examiner.user.name),
                        size: 32,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      SizedBox(width: AppTheme.spaceSM),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            examiner.user.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          sha.Button.text(
                            onPressed: () {},
                            style: const sha.ButtonStyle.ghost(
                              density: sha.ButtonDensity.compact,
                            ),
                            child: Text(
                              examiner.user.email,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: AppTheme.spaceLG)
                    ],
                  ),
                );
              }),
            ],
          )
        ],
      ],
    );
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

    var thesisLecture = ThesisLecture(
      user: lecturer,
      role: ThesisLectureRole.supervisor,
    );

    final errorMessage = await ThesisController.to.assignSupervisor(
      widget.thesis,
      thesisLecture,
    );

    if (errorMessage != null) {
      if (!mounted) return;
      return MyToast.showShadcnUIToast(
        context,
        'Error',
        errorMessage,
        isError: true,
      );
    } else {
      if (!mounted) return;
      MyToast.showShadcnUIToast(
        context,
        'Success',
        '${lecturer.name} has been assigned as supervisor',
        isError: false,
      );
      await _loadThesis();
    }
  }

  Future<void> _assignExaminer(
      User lecturer, ThesisLectureExaminerType type) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Examiner'),
        content: Text(
          'Are you sure you want to assign ${lecturer.name} as ${type.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    var thesisLecture = ThesisLecture(
      user: lecturer,
      role: ThesisLectureRole.examiner,
      examinerType: type,
    );

    final errorMessage = await ThesisController.to.assignExaminer(
      widget.thesis,
      thesisLecture,
    );

    if (errorMessage != null) {
      if (!mounted) return;
      return MyToast.showShadcnUIToast(
        context,
        'Error',
        errorMessage,
        isError: true,
      );
    }

    if (!mounted) return;
    MyToast.showShadcnUIToast(
      context,
      'Success',
      '${lecturer.name} has been assigned as ${type.name}',
      isError: false,
    );
    await _loadThesis();
  }

  Future<void> _showAssignLecturerDialog({
    required String title,
    required String role,
    required Function(User) onAssign,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0.0,
                centerTitle: false,
                forceMaterialTransparency: true,
                // toolbarHeight: 60,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assign $title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                child: Text(
                  'Select a available lecturer below to assign as $role',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: AppTheme.spaceMD),
              Flexible(
                child: Obx(() {
                  if (ThesisController.to.isLoadingMyThesis) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lecturers = AdminController.to.lecturers;

                  // Get current examiners based on type
                  var finalDefenseExaminers = widget.thesis.examiners
                      .where((e) =>
                          e.examinerType ==
                          ThesisLectureExaminerType.finalDefenseExaminer)
                      .toList();

                  var proposalDefenseExaminers = widget.thesis.examiners
                      .where((e) =>
                          e.examinerType ==
                          ThesisLectureExaminerType.proposalDefenseExaminer)
                      .toList();

                  // Filter lecturers based on current assignment state and thesis status
                  final filteredLecturers = lecturers.where((lecturer) {
                    // Always exclude supervisors
                    if (widget.thesis.supervisors
                        .any((e) => e.user.id == lecturer.id)) {
                      return false;
                    }

                    // For proposal defense examiner selection
                    if (!widget.thesis.isProposalReady &&
                        proposalDefenseExaminers.isEmpty) {
                      // If selecting proposal examiner and none assigned yet
                      // Exclude final defense examiners
                      return !finalDefenseExaminers
                          .any((e) => e.user.id == lecturer.id);
                    }

                    // For final defense examiner selection
                    if (widget.thesis.isProposalReady &&
                        !widget.thesis.isFinalExamReady &&
                        finalDefenseExaminers.isEmpty) {
                      // If selecting final examiner and none assigned yet
                      // Can include proposal examiners (they can be final examiners too)
                      return true;
                    }

                    // Default case: exclude already assigned examiners of the current type
                    if (widget.thesis.isProposalReady) {
                      // If assigning final examiner
                      return !finalDefenseExaminers
                          .any((e) => e.user.id == lecturer.id);
                    } else {
                      // If assigning proposal examiner
                      return !proposalDefenseExaminers
                          .any((e) => e.user.id == lecturer.id);
                    }
                  }).toList();

                  if (filteredLecturers.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No lecturers available',
                      message: 'Please add lecturers first',
                      icon: Iconsax.user_tag,
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredLecturers.length,
                    itemBuilder: (context, index) {
                      final lecturer = filteredLecturers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            lecturer.name[0].toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                        title: Text(lecturer.name),
                        subtitle: Text(lecturer.email),
                        onTap: () {
                          Navigator.pop(context);
                          onAssign(lecturer);
                        },
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: AppTheme.spaceMD),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approveThesis(String type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Thesis for $type'),
        content:
            Text('Are you sure you want to approve this thesis for $type?'),
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
      final errorMessage = await ThesisController.to.approveThesisForDefense(
        widget.thesis.id,
      );

      if (errorMessage != null) {
        if (!mounted) return;
        return MyToast.showShadcnUIToast(
          context,
          'Error',
          errorMessage,
          isError: true,
        );
      }

      if (!mounted) return;
      return MyToast.showShadcnUIToast(
        context,
        'Success',
        'Thesis approved successfully',
        isError: false,
      );
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
      await ThesisController.to.markAsCompleted(widget.thesis.id);
      await _loadThesis();
    }
  }

  /// List of members dialog
  void _showListOfMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0.0,
                centerTitle: false,
                forceMaterialTransparency: true,
                // toolbarHeight: 60,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team Members',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spaceXS),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.thesis.members.value.lecturers.length +
                      1, // +1 for student
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        onTap: () {},
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          widget.thesis.members.value.student.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Text(
                          widget.thesis.members.value.student.role.name,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            widget.thesis.members.value.student.name[0],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      );
                    }

                    final member =
                        widget.thesis.members.value.lecturers[index - 1];
                    return ListTile(
                      onTap: () {},
                      visualDensity: VisualDensity.compact,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          member.user.name[0],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                      title: Text(
                        member.user.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Text(
                        (member.role == ThesisLectureRole.examiner)
                            ? member.examinerType?.name ?? ''
                            : member.role.name,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
