import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/admin_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _adminController = Get.find<AdminController>();
  final _searchController = TextEditingController();
  final _selectedRole = 'all'.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }  

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _adminController.deleteUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppTheme.spaceLG),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Iconsax.search_normal, size: 16),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? UnconstrainedBox(
                            child: IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                          )
                        : null,
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide.none,
                    //   borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    // ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderSide: BorderSide.none,
                    //   borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    // ),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      minWidth: 300,
                      maxHeight: 40,
                    ),
                  ),
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
                        value: 'student',
                        label: Text('Students'),
                      ),
                      ButtonSegment(
                      value: 'lecture',
                        label: Text('Lecturers'),
                      ),
                    ],
                  style: SegmentedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelMedium,
                    minimumSize: const Size(300, 40),
                  ),
                  showSelectedIcon: false,
                    selected: {_selectedRole.value},
                    onSelectionChanged: (values) {
                      _selectedRole.value = values.first;
                    },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final users = _adminController.users.where((user) {
              final matchesSearch = user.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()) ||
                  user.email
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

              final matchesRole = _selectedRole.value == 'all' ||
                  user.role.name.toLowerCase() == _selectedRole.value;

              return matchesSearch && matchesRole;
            }).toList();

            if (users.isEmpty && !_adminController.isUserLoading) {
              return const EmptyStateWidget(
                message: 'No users found',
                icon: Icons.group_off_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: _adminController.getAllUsers,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLG,
                ),
                itemCount: users.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: AppTheme.spaceSM,
                ),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMD,
                      vertical: AppTheme.spaceXS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: user.role.color.withOpacity(0.1),
                      foregroundColor: user.role.color,
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${user.email} • ',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  user.role.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: user.role.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // --- Lecturer Stats ---
                        if (user.role == UserRole.lecturer)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceMD,
                            ),
                            child: Row(
                              spacing: 16,
                              children: [
                                // Total Theses Supervised
                                Tooltip(
                                  message: 'Total Theses Supervised',
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppTheme.spaceMD,
                                      horizontal: AppTheme.spaceSM,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.cardRadius),
                                    ),
                                    child: Column(
                                      spacing: 4,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4,
                                          children: [
                                            const Icon(Iconsax.archive_tick,
                                                size: 16),
                                            Text(
                                              '${(user.data as LecturerData).totalThesisSupervised}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Supervised',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // --- Total Theses Examined ---
                                Tooltip(
                                  message: 'Total Theses Examined',
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppTheme.spaceMD,
                                      horizontal: AppTheme.spaceSM,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.cardRadius),
                                    ),
                                    child: Column(
                                      spacing: 4,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4,
                                          children: [
                                            const Icon(Iconsax.teacher,
                                                size: 16),
                                            Text(
                                              '${(user.data as LecturerData).totalThesisExamined}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Examined',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // --- On Track Theses ---
                                Tooltip(
                                  message: 'On Track Theses Supervised',
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppTheme.spaceMD,
                                      horizontal: AppTheme.spaceSM,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.cardRadius),
                                    ),
                                    child: Column(
                                      spacing: 4,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4,
                                          children: [
                                            const Icon(Iconsax.flash, size: 16),
                                            Text(
                                              '${(user.data as LecturerData).onTrackThesisCount}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'On Track',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      iconColor: Theme.of(context).colorScheme.outlineVariant,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceSM,
                          ),
                          height: 30,
                          child: Row(
                            children: [
                              const Icon(Iconsax.trash, size: 16),
                              SizedBox(width: AppTheme.spaceSM),
                              Text(
                                'Delete',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteUser(user);
                        }
                      },
                    ),
                  );
                },
              ),
            ).asSkeleton(
              enabled: _adminController.isUserLoading,
            );
          }),
        ),
        SizedBox(height: AppTheme.spaceLG),
      ],
    );
  }
}
