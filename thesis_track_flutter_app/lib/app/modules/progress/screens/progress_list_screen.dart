import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Progress;
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/button.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/skeleton.dart';

class ProgressListScreen extends StatefulWidget {
  const ProgressListScreen({
    super.key,
    required this.thesisId,
  });

  final String thesisId;

  @override
  State<ProgressListScreen> createState() => _ProgressListScreenState();
}

class _ProgressListScreenState extends State<ProgressListScreen> {
  final _progressController = Get.find<ProgressController>();
  final _authController = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _selectedStatus = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    if (_authController.user?.role == 'lecturer') {
      await _progressController.getProgressesByReviewer(widget.thesisId);
    } else {
      await _progressController.getProgressesByThesis(widget.thesisId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Progress List',
      ),
      body: PageLayout(
        compactLayout: SinglePaneLayout(
          child: _buildContent(theme),
        ),
        mediumLayout: SinglePaneLayout(
          child: _buildContent(theme),
        ),
        expandedLayout: SinglePaneLayout(
          child: _buildContent(theme),
        ),
      ),
      floatingActionButton: _authController.user?.role == 'student'
          ? ThesisFloatingActionButton(
              icon: Iconsax.add,
              label: 'Add Progress',
              extended: true,
              onPressed: () =>
                  context.go('/progress/thesis/${widget.thesisId}/create'),
            )
          : null,
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
        // Search and Filter
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search progress...',
                  leading: const Icon(Iconsax.search_normal),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                  ],
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Obx(() => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('All'),
                      ),
                      ButtonSegment(
                        value: 'pending',
                        label: Text('Pending'),
                      ),
                      ButtonSegment(
                        value: 'reviewed',
                        label: Text('Reviewed'),
                      ),
                    ],
                    selected: {_selectedStatus.value},
                    onSelectionChanged: (values) {
                      _selectedStatus.value = values.first;
                    },
                  )),
            ],
          ),
        ),
        // Progress List
        Expanded(
          child: Obx(() {
            if (_progressController.isLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) => const ProgressCardSkeleton(),
              );
            }

            final filteredProgress =
                _progressController.progresses.where((progress) {
              final matchesSearch = progress.progressDescription
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());

              final matchesStatus = _selectedStatus.value == 'all' ||
                  (_selectedStatus.value == 'pending' &&
                      progress.status.toLowerCase() == 'pending') ||
                  (_selectedStatus.value == 'reviewed' &&
                      progress.status.toLowerCase() == 'reviewed');

              return matchesSearch && matchesStatus;
            }).toList();

            if (filteredProgress.isEmpty) {
              return EmptyStateWidget(
                message: _searchController.text.isNotEmpty
                    ? 'No progress found for "${_searchController.text}"'
                    : 'No progress records yet',
                icon: Iconsax.clipboard_close,
                actionLabel: _authController.user?.role == 'student'
                    ? 'Add Progress'
                    : null,
                onAction: _authController.user?.role == 'student'
                    ? () =>
                        context.go('/progress/thesis/${widget.thesisId}/create')
                    : null,
              );
            }

            return RefreshIndicator(
              onRefresh: _loadProgress,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProgress.length,
                itemBuilder: (context, index) {
                  final progress = filteredProgress[index];
                  return _buildProgressCard(progress, theme);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProgressCard(Progress progress, ThemeData theme) {
    final hasDocument = progress.documentUrl != null;
    final formattedDate = _formatDate(progress.achievementDate);

    return ThesisCard(
      onTap: () => context.go('/progress/${progress.id}/detail'),
      margin: const EdgeInsets.only(bottom: 16),
      hasBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  progress.reviewer.name[0].toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.reviewer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ThesisStatusChip(status: progress.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            progress.progressDescription,
            style: theme.textTheme.bodyLarge,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasDocument) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.document_normal,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Document attached',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
