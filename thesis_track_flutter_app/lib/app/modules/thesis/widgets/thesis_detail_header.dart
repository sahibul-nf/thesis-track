import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
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
                icon: ThesisController.to.isLoading
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
                  SizedBox(
                    width: 200,
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
                        if (RoleGuard.canAssignSupervisor(widget.thesis.status))
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

                        if (RoleGuard.canAssignExaminer(widget.thesis))
                          CustomMenuItem(
                            onTap: () {
                              _showAssignLecturerDialog(
                                title: 'Examiner',
                                role: 'examiner',
                                onAssign: _assignExaminer,
                              );
                            },
                            leading: const Icon(Iconsax.verify, size: 18),
                            title: 'Assign Examiner',
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
                            title: 'Accept Thesis',
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
      var canAccept = RoleGuard.canAcceptThesisSubmission(thesis);
      var canMarkAsCompleted = RoleGuard.canMarkAsCompleted(thesis);

      return Visibility(
        visible: canApproveProposalDefense ||
            canApproveFinalDefense ||
            canAccept ||
            canMarkAsCompleted,
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
                  if (canAccept)
                    FilledButton(
                      onPressed: () {
                        _showAcceptThesisDialog();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 44),
                      ),
                      child: const Text('Accept Thesis'),
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
    final (icon, color) = _getResearchFieldIconAndColor(researchField);

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
        title: const Text('Accept Thesis'),
        content: const Text('Are you sure you want to accept this thesis?'),
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

  (IconData, Color) _getResearchFieldIconAndColor(String researchField) {
    // Lowercase dan hapus spasi untuk memudahkan matching
    final field = researchField.toLowerCase().replaceAll(' ', '');

    switch (field) {
      // Computer Science / IT
      case 'artificialintelligence':
      case 'machinelearning':
        return (Iconsax.component, const Color(0xFF7B61FF)); // Purple
      case 'computernetworks':
      case 'networking':
        return (Iconsax.global, const Color(0xFF2196F3)); // Blue
      case 'cybersecurity':
      case 'security':
        return (Iconsax.shield_tick, const Color(0xFF4CAF50)); // Green
      case 'datascience':
      case 'bigdata':
        return (Iconsax.data, const Color(0xFF00BCD4)); // Cyan
      case 'mobiledevelopment':
      case 'mobilecomputing':
        return (Iconsax.mobile, const Color(0xFF3F51B5)); // Indigo
      case 'webdevelopment':
        return (Iconsax.code, const Color(0xFF009688)); // Teal
      case 'cloudcomputing':
        return (Iconsax.cloud, const Color(0xFF03A9F4)); // Light Blue
      case 'iot':
      case 'internetofthings':
        return (Iconsax.wifi, const Color(0xFF00BFA5)); // Teal Accent
      case 'blockchain':
        return (Iconsax.text_block, const Color(0xFF607D8B)); // Blue Grey
      case 'gamedev':
      case 'gamedevelopment':
        return (Iconsax.game, const Color(0xFFE91E63)); // Pink

      // Information Systems
      case 'informationsystems':
      case 'mis':
        return (Iconsax.diagram, const Color(0xFF9C27B0)); // Purple
      case 'businessintelligence':
        return (Iconsax.chart_2, const Color(0xFF673AB7)); // Deep Purple
      case 'erp':
      case 'enterpriseresourceplanning':
        return (Iconsax.building_4, const Color(0xFF3949AB)); // Indigo

      // Software Engineering
      case 'softwareengineering':
      case 'softwaredevelopment':
        return (Iconsax.code_1, const Color(0xFF1E88E5)); // Blue
      case 'systemdesign':
        return (Iconsax.hierarchy_square_2, const Color(0xFF00897B)); // Teal
      case 'testing':
      case 'qualityassurance':
        return (Iconsax.tick_square, const Color(0xFF43A047)); // Green

      // Default colors based on first letter for variety
      default:
        final firstChar = field.isEmpty ? 'a' : field[0];
        IconData icon;
        Color color;

        switch (firstChar) {
          case 'a':
          case 'b':
            icon = Iconsax.document_text;
            color = const Color(0xFFF44336); // Red
            break;
          case 'c':
          case 'd':
            icon = Iconsax.document_code;
            color = const Color(0xFFE91E63); // Pink
            break;
          case 'e':
          case 'f':
            icon = Iconsax.document_favorite;
            color = const Color(0xFF9C27B0); // Purple
            break;
          case 'g':
          case 'h':
            icon = Iconsax.document_cloud;
            color = const Color(0xFF673AB7); // Deep Purple
            break;
          case 'i':
          case 'j':
            icon = Iconsax.document_normal;
            color = const Color(0xFF3F51B5); // Indigo
            break;
          case 'k':
          case 'l':
            icon = Iconsax.document_filter;
            color = const Color(0xFF2196F3); // Blue
            break;
          case 'm':
          case 'n':
            icon = Iconsax.document_forward;
            color = const Color(0xFF03A9F4); // Light Blue
            break;
          case 'o':
          case 'p':
            icon = Iconsax.document_download;
            color = const Color(0xFF00BCD4); // Cyan
            break;
          case 'q':
          case 'r':
            icon = Iconsax.document_upload;
            color = const Color(0xFF009688); // Teal
            break;
          case 's':
          case 't':
            icon = Iconsax.document_text_1;
            color = const Color(0xFF4CAF50); // Green
            break;
          case 'u':
          case 'v':
            icon = Iconsax.document_like;
            color = const Color(0xFF8BC34A); // Light Green
            break;
          default:
            icon = Iconsax.document_text;
            color = const Color(0xFF607D8B); // Blue Grey
        }
        return (icon, color);
    }
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

    final errorMessage = await ThesisController.to.assignSupervisor(
      widget.thesis.id,
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

    final errorMessage = await ThesisController.to.assignExaminer(
      widget.thesis.id,
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
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 500,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign $title',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppTheme.spaceMD),
                Flexible(
                  child: Obx(() {
                    if (ThesisController.to.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lecturers = AdminController.to.lecturers;
                    if (lecturers.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No lecturers available',
                        message: 'Please add lecturers first',
                        icon: Iconsax.user_tag,
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: lecturers.length,
                      itemBuilder: (context, index) {
                        final lecturer = lecturers[index];
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
                          subtitle: Text(lecturer.department ?? ''),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
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
                  itemCount: widget.thesis.members.lecturers.length +
                      1, // +1 for student
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        onTap: () {},
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          widget.thesis.members.student.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Text(
                          widget.thesis.members.student.role.name,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            widget.thesis.members.student.name[0],
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

                    final member = widget.thesis.members.lecturers[index - 1];
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
