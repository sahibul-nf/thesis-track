import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/widgets/thesis_list_view.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/custom_menu_item.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/popup_menu.dart';

class BrowseThesisScreen extends StatefulWidget {
  const BrowseThesisScreen({super.key});

  @override
  State<BrowseThesisScreen> createState() => _BrowseThesisScreenState();
}

class _BrowseThesisScreenState extends State<BrowseThesisScreen> {
  final searchController = TextEditingController();
  final controller = ThesisController.to;
  final statusMenuController = MenuController();

  String _getScreenTitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Find Research Topics';
      case UserRole.lecturer:
        return 'Browse Student Theses';
      case UserRole.admin:
        return 'Manage Thesis Database';
      default:
        return 'Browse Theses';
    }
  }

  String _getScreenDescription(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Explore existing thesis topics to avoid duplicates and get inspiration for your research. Make sure your topic is unique!';
      case UserRole.lecturer:
        return 'Review ongoing and completed theses from students. Search through the database to check for similar research topics.';
      case UserRole.admin:
        return 'Comprehensive database of all thesis submissions. Use search to find and manage specific thesis entries.';
      default:
        return 'Search through existing theses to avoid duplicate topics and get inspiration for your research.';
    }
  }

  String _getSearchHint(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Search topics like "Machine Learning", "IoT", "Data Mining"...';
      case UserRole.lecturer:
        return 'Search by title, research field, or student name...';
      case UserRole.admin:
        return 'Search any thesis details...';
      default:
        return 'Try searching "Machine Learning", "IoT", etc...';
    }
  }

  Widget _getEmptyStateContent(
      UserRole role, BuildContext context, String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return EmptyStateWidget(
        title: 'No Matching Theses Found',
        message:
            "We couldn't find any theses matching '$searchQuery'. Try different keywords or browse all theses by clearing the search.",
        icon: Iconsax.search_normal,
        actionLabel: 'Clear search',
        actionIcon: Iconsax.close_circle,
        onAction: () {
          searchController.clear();
          controller.updateSearch('');
        },
        buttonSize: const Size(140, 48),
      );
    }

    switch (role) {
      case UserRole.student:
        return EmptyStateWidget(
          title: 'Start Your Research Journey',
          message:
              "No thesis submissions yet. This is your chance to pioneer a unique research topic! Browse later to see other students' work.",
          icon: Iconsax.document_text,
          actionLabel: 'Refresh',
          actionIcon: Iconsax.refresh,
          onAction: () => controller.getAllTheses(),
          buttonSize: const Size(140, 48),
        );
      case UserRole.lecturer:
        return EmptyStateWidget(
          title: 'No Thesis Submissions Yet',
          message:
              "Waiting for student thesis submissions. You'll be notified when students submit their proposals.",
          icon: Iconsax.document_text,
          actionLabel: 'Refresh',
          actionIcon: Iconsax.refresh,
          onAction: () => controller.getAllTheses(),
          buttonSize: const Size(140, 48),
        );
      case UserRole.admin:
        return EmptyStateWidget(
          title: 'Database is Empty',
          message:
              "The thesis database is currently empty. New submissions will appear here automatically.",
          icon: Iconsax.document_text,
          actionLabel: 'Refresh',
          actionIcon: Iconsax.refresh,
          onAction: () => controller.getAllTheses(),
          buttonSize: const Size(140, 48),
        );
      default:
        return EmptyStateWidget(
          title: 'No Theses Available Yet',
          message:
              "No thesis submissions available at the moment. Check back later!",
          icon: Iconsax.document_text,
          actionLabel: 'Refresh',
          actionIcon: Iconsax.refresh,
          onAction: () => controller.getAllTheses(),
          buttonSize: const Size(140, 48),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = AuthController.to.user?.role ?? UserRole.student;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getScreenDescription(userRole),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: AppTheme.spaceMD),
              Row(
                spacing: AppTheme.spaceLG,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: _getSearchHint(userRole),
                        prefixIcon: const Icon(Iconsax.search_normal, size: 16),
                        suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Iconsax.close_circle),
                                iconSize: 16,
                                onPressed: () {
                                  searchController.clear();
                                  controller.updateSearch('');
                                },
                              )
                            : const SizedBox.shrink()),
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxHeight: 40,
                        ),
                      ),
                      onChanged: controller.updateSearch,
                    ),
                  ),
                  Flexible(
                    child: PopupMenu(
                      controller: statusMenuController,
                      builder: (context, contr, child) {
                        return FilledButton.tonalIcon(
                          onPressed: () {
                            contr.open(
                              position: Offset(
                                MediaQuery.of(context).size.width - 100,
                                100,
                              ),
                            );
                          },
                          label: Text(
                            controller.selectedStatus.value?.name ?? 'All',
                            style: theme.textTheme.labelLarge,
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.secondary.withOpacity(0.1),
                            foregroundColor: theme.colorScheme.secondary,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(80, 45),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceMD,
                            ),
                          ),
                        );
                      },
                      menuChildren: [
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              CustomMenuItem(
                                title: 'All',
                                onTap: () {
                                  controller.updateStatusFilter(null);
                                  statusMenuController.close();
                                },
                              ),
                              ...ThesisStatus.values.skip(1).map(
                                    (status) => CustomMenuItem(
                                      title: status.name,
                                      onTap: () {
                                        controller.updateStatusFilter(status);
                                        statusMenuController.close();
                                      },
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                final resultCount = controller.filteredTheses.length;
                if (controller.searchQuery.isNotEmpty ||
                    controller.selectedStatus.value != null) {
                  return Row(
                    children: [
                      Text(
                        'Found $resultCount ${resultCount == 1 ? 'thesis' : 'theses'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (controller.selectedStatus.value != null) ...[
                        Text(
                          ' with status ',
                          style: theme.textTheme.bodySmall,
                        ),
                        ThesisStatusChip(
                          status: controller.selectedStatus.value?.name ??
                              'All',
                        ),
                      ],
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            var theses = controller.filteredTheses;

            if (theses.isEmpty && !controller.isLoadingAllTheses) {
              return _getEmptyStateContent(
                  userRole, context, controller.searchQuery);
            }

            if (controller.isLoadingAllTheses) {
              return ThesisListView(theses: mockOtherTheses).asSkeleton();
            }

            return ThesisListView(theses: theses);
          }),
        ),
      ],
    );
  }
}
