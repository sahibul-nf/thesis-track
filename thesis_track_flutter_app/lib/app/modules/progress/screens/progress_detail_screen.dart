import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Progress;
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/data/models/comment_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/loading.dart';
import 'package:thesis_track_flutter_app/app/widgets/text_field.dart';

class ProgressDetailScreen extends StatefulWidget {
  final ProgressModel progress;

  const ProgressDetailScreen({
    super.key,
    required this.progress,
  });

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  final _progressController = Get.find<ProgressController>();
  final _authController = Get.find<AuthController>();
  final _commentController = TextEditingController();
  final _replyController = TextEditingController();
  String? _replyToId;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    await _progressController.getProgressById(widget.progress.id);
    await _progressController.getCommentsByProgress(widget.progress.id);
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final success = await _progressController.addComment(
      progress: widget.progress,
      content: _commentController.text,
    );

    if (success != null) {
      _commentController.clear();
      await _loadProgress();
    }
  }

  Future<void> _addReply(String parentId) async {
    if (_replyController.text.isEmpty) return;

    final success = await _progressController.addComment(
      progress: widget.progress,
      content: _replyController.text,
      parentId: parentId,
    );

    if (success != null) {
      _replyController.clear();
      _replyToId = null;
      await _loadProgress();
    }
  }

  Future<void> _reviewProgress(String status) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status.capitalize} Progress'),
        content: Text(
          'Are you sure you want to mark this progress as ${status.toLowerCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: status == 'approved'
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            child: Text(status.capitalize!),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _progressController.reviewProgress(
      progress: widget.progress,
      comment: 'Progress marked as $status',
    );

    if (success != null) {
      await _loadProgress();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress has been marked as ${status.toLowerCase()}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Progress Detail',
      ),
      body: Obx(() {
        if (_progressController.isLoading) {
          return const LoadingWidget();
        }

        final progress = _progressController.selectedProgress;
        if (progress == null) {
          return const EmptyStateWidget(
            message: 'Progress not found',
            icon: Icons.error_outline,
          );
        }

        final isReviewer = _authController.user?.id == progress.reviewerId;
        final canReview = isReviewer && progress.status == 'pending';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ThesisCard(
              title: 'Progress Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.progressDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviewer',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              progress.reviewer.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        return ThesisStatusChip(status: progress.status.value);
                      }),
                    ],
                  ),
                  if (progress.documentUrl != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.attach_file),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            progress.documentUrl!.split('/').last,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: () {
                            // TODO: Implement document download
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download'),
                        ),
                      ],
                    ),
                  ],
                  if (canReview) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Review Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _reviewProgress('approved'),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _reviewProgress('rejected'),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (RoleGuard.canAddComment()) ...[
              ThesisCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThesisTextField(
                      controller: _commentController,
                      label: 'Add Comment',
                      hint: 'Write your comment here...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _addComment,
                      child: const Text('Post Comment'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (progress.comments.isEmpty)
              const EmptyStateWidget(
                message: 'No comments yet',
                icon: Icons.chat_bubble_outline,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: progress.comments.length,
                itemBuilder: (context, index) {
                  final comment = progress.comments[index];
                  return _buildCommentCard(comment);
                },
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    final isCommentOwner = _authController.user?.id == comment.user.id;
    final canReply = RoleGuard.canAddComment();

    return ThesisCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  comment.user.name[0].toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      comment.userType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            comment.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (canReply) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _replyToId = _replyToId == comment.id ? null : comment.id;
                });
              },
              child: Text(_replyToId == comment.id ? 'Cancel' : 'Reply'),
            ),
          ],
          if (_replyToId == comment.id) ...[
            const SizedBox(height: 8),
            ThesisTextField(
              controller: _replyController,
              hint: 'Write your reply...',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _addReply(comment.id),
              child: const Text('Post Reply'),
            ),
          ],
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comment.replies.length,
              itemBuilder: (context, index) {
                final reply = comment.replies[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 16),
                  child: _buildCommentCard(reply),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
