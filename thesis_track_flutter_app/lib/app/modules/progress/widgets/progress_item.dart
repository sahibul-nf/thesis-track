import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/custom_menu_item.dart';
import 'package:thesis_track_flutter_app/app/widgets/popup_menu.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class ProgressItem extends StatefulWidget {
  const ProgressItem({super.key, required this.progress, required this.index});
  final ProgressModel progress;
  final int index;

  @override
  State<ProgressItem> createState() => _ProgressItemState();
}

class _ProgressItemState extends State<ProgressItem> {
  final _commentControllers = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final showMoreComments = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.progress;
    final index = widget.index;

    return ThesisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppTheme.spaceXS,
                  children: [
                    Text(
                      progress.progressDescription,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Created ${DateFormat('dd MMM yyyy').format(progress.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Option Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: AppTheme.spaceMD,
                children: [
                  Obx(() {
                    return ThesisStatusChip(
                      status: progress.status.value,
                      textColor: _getProgressStatusColor(progress.status.value),
                      backgroundColor:
                          _getProgressStatusColor(progress.status.value)
                              .withOpacity(0.1),
                    );
                  }),
                  PopupMenu(
                    builder: (context, c, child) {
                      return IconButton(
                        onPressed: () {
                          var buttonPosition =
                              Offset(MediaQuery.of(context).size.width, 70);

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
                        width: 170,
                        child: Column(
                          children: [
                            // Edit Progress
                            if (RoleGuard.canEditProgress())
                              CustomMenuItem(
                                onTap: () {
                                  MyToast.showComingSoonToast(context);
                                },
                                leading: const Icon(Iconsax.edit, size: 18),
                                title: 'Edit',
                              ),
                            // Delete Progress
                            if (RoleGuard.canDeleteProgress())
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
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),

          // Assigned Reviewer
          ...[
            Text(
              'Assigned to',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppTheme.spaceSM),
            UnconstrainedBox(
              child: Container(
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
                      initials: sha.Avatar.getInitials(progress.reviewer.name),
                      size: 32,
                      // backgroundColor: theme.colorScheme.,
                    ),
                    SizedBox(width: AppTheme.spaceSM),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.reviewer.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        sha.Button.text(
                          onPressed: () {},
                          style: const sha.ButtonStyle.ghost(
                            density: sha.ButtonDensity.compact,
                          ),
                          child: Text(
                            'Reviewer',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: AppTheme.spaceMD),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spaceMD),
          ],

          // Document Section
          if (progress.documentUrl != null) ...[
            InkWell(
              onTap: () {
                _openDocument(progress.documentUrl!);
              },
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              child: Ink(
                padding: EdgeInsets.all(AppTheme.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  // border: Border.all(
                  //   color: theme.colorScheme.outline.withOpacity(0.1),
                  // ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spaceSM),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.cardRadius),
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
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppTheme.spaceXS,
                        children: [
                          Text(
                            'Document Attached',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Click to view document',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle document view/download
                        _openDocument(progress.documentUrl!);
                      },
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spaceSM),
          ],

          // Comments Section
          if (RoleGuard.canAddComment()) ...[
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            SizedBox(height: AppTheme.spaceSM),
            if (progress.comments.isNotEmpty)
              Obx(() {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
                  child: Text(
                    'Comments (${progress.comments.length})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            // Comments List
            Obx(() {
              var comments = showMoreComments.value
                  ? progress.comments
                  : progress.comments.take(3).toList();

              return ListView.builder(
                itemCount: comments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.spaceSM,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              theme.colorScheme.secondary.withOpacity(0.1),
                          child: Text(
                            comment.user.name[0].toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.user.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spaceXS),
                                  Text(
                                    '• ${timeago.format(comment.createdAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppTheme.spaceXS),
                              Text(
                                comment.content,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            Obx(() {
              if (progress.comments.length > 3) {
                return TextButton(
                  onPressed: () {
                    showMoreComments.value = !showMoreComments.value;
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child:
                      Text(showMoreComments.value ? 'Show Less' : 'Show More'),
                );
              }

              return const SizedBox.shrink();
            }),
          ],

          // Add Comment TextField
          if (RoleGuard.canAddComment())
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: AppTheme.spaceMD),
                  TextFormField(
                    controller: _commentControllers,
                    minLines: 1,
                    maxLines: 4,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: () {
                        if (progress.status.toLowerCase() != 'reviewed') {
                          return 'Share your thoughts and suggestions...';
                        }
                        return 'Add your comment here...';
                      }(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        if (RoleGuard.canReviewProgress(progress)) {
                          return 'Please write your review comment before marking as reviewed';
                        } else {
                          return 'Comment cannot be empty';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppTheme.spaceSM),
                  Obx(() {
                    var isLoading = ProgressController.to.isSendingComment;
                    var canReview = RoleGuard.canReviewProgress(progress) &&
                        progress.status.toLowerCase() != 'reviewed';

                    return FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (canReview) {
                                _submitReview(progress);
                              } else {
                                _submitComment(progress);
                              }
                            },
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        disabledBackgroundColor:
                            theme.colorScheme.primary.withOpacity(0.5),
                        disabledForegroundColor:
                            theme.colorScheme.onPrimary.withOpacity(0.5),
                        minimumSize: const Size(140, 48),
                      ),
                      icon: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Iconsax.send_2, size: 20),
                      label: canReview
                          ? Text(
                              'Approve & Mark as Reviewed',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              'Send',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _submitComment(ProgressModel progress) async {
    if (!_formKey.currentState!.validate()) return;

    final progressController = ProgressController.to;

    final err = await progressController.addComment(
      progress: progress,
      content: _commentControllers.text,
    );

    if (err != null) {
      MyToast.showShadcnUIToast(
        context,
        'Oops! We couldn\'t add your comment. Please try again',
        err,
        isError: true,
      );
      return;
    }

    _commentControllers.clear();
    _formKey.currentState!.reset();
  }

  void _submitReview(ProgressModel progress) async {
    if (!_formKey.currentState!.validate()) return;

    final progressController = ProgressController.to;

    final err = await progressController.reviewProgress(
      progress: progress,
      comment: _commentControllers.text,
    );

    if (err != null) {
      MyToast.showShadcnUIToast(
        context,
        'Oops! We couldn\'t submit your progress review. Please try again',
        err,
        isError: true,
      );
      return;
    }

    _commentControllers.clear();
    _formKey.currentState!.reset();
  }

  Color _getProgressStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successColor;
      case 'in_progress':
        return AppTheme.primaryColor;
      case 'pending':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _openDocument(String url) {
    launchUrl(Uri.parse(url));
  }
}
