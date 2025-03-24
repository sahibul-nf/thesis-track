import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Progress;
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/widgets/document_section.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/widgets/progress_session_list.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/widgets/thesis_detail_header.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class ThesisDetailScreen extends StatefulWidget {
  const ThesisDetailScreen({
    super.key,
    required this.thesis,
    this.isEmbedded = false,
  });

  final Thesis thesis;
  final bool isEmbedded;

  @override
  State<ThesisDetailScreen> createState() => _ThesisDetailScreenState();
}

class _ThesisDetailScreenState extends State<ThesisDetailScreen> {
  final _thesisController = Get.find<ThesisController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();    
  }

  Future<void> _loadThesis() async {
    await _thesisController.getThesisById(widget.thesis.id);
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
      await _thesisController.acceptThesis(
        widget.thesis.id,
        widget.thesis.supervisorId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thesis = widget.thesis;

    final userRole = AuthController.to.user?.role;
    final isPending = thesis.status == ThesisStatus.pending;

    // For Admin with Pending Thesis
    if (userRole == UserRole.admin && isPending) {
      return Obx(() {
        return Column(
          children: [
            ThesisDetailHeader(thesis: thesis),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: EmptyStateWidget(
                  isLoading: ThesisController.to.isLoadingMyThesis,
                  icon: Iconsax.clipboard_text,
                  title: 'Thesis Proposal Review',
                  message:
                      'A new thesis proposal awaits your review. \nPlease examine the details carefully before making your decision to accept or reject.',
                  actionLabel: 'Accept Proposal',
                  onAction: _showAcceptThesisDialog,
                  buttonSize: const Size(150, 48),
                ),
              ),
            ),
          ],
        );
      });
    }

    // For Student with Pending Thesis
    if (userRole == UserRole.student && isPending) {
      return Column(
        children: [
          ThesisDetailHeader(thesis: thesis),
          const Divider(height: 1),
          Expanded(
            child: Center(
              child: EmptyStateWidget(
                icon: Iconsax.timer,
                title: 'Waiting for Approval',
                message:
                    'Your thesis proposal is being reviewed by the admin. You\'ll be notified once it\'s approved.',
                actionLabel: 'Refresh',
                actionIcon: Iconsax.refresh,
                onAction: _loadThesis,
                buttonSize: const Size(150, 48),
              ),
            ),
          ),
        ],
      );
    }

    // For Lecturer with Pending Thesis
    if (userRole == UserRole.lecturer && isPending) {
      return Scaffold(
        body: Column(
          children: [
            ThesisDetailHeader(thesis: thesis),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: EmptyStateWidget(
                  icon: Iconsax.clock,
                  title: 'Pending Approval',
                  message:
                      'This thesis is awaiting administrative approval before supervision can begin.',
                  actionLabel: 'Refresh',
                  actionIcon: Iconsax.refresh,
                  onAction: _loadThesis,
                  buttonSize: const Size(150, 48),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: _loadThesis,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Header Title & Quick Stats Section
            SliverToBoxAdapter(child: ThesisDetailHeader(thesis: thesis)),
        
            // Divider
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),
        
            // Progress & Documents Sections
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                tabBar: TabBar(
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: theme.dividerColor.withOpacity(0.15),
                  // dividerHeight: 0,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppTheme.spaceSM,
                        children: const [
                          Icon(Iconsax.task_square, size: 18),
                          Text('Progress'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppTheme.spaceSM,
                        children: const [
                          Icon(Iconsax.document_text, size: 18),
                          Text('Documents'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ProgressSessionList(
                thesis: thesis,
              ),
              DocumentSection(thesis: thesis),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate({required this.tabBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
