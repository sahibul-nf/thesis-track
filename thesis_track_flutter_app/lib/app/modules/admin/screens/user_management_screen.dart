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

  Future<void> _updateUserRole(User user, String newRole) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: Text(
          'Are you sure you want to change ${user.name}\'s role to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _adminController.updateUserRole(
        userId: user.id,
        role: newRole,
      );

      await _adminController.getAllUsers();
    }
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
      await _adminController.deleteUser(user.id);
      await _adminController.getAllUsers();
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
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spaceSM,
                                vertical: AppTheme.spaceXS,
                              ),
                              decoration: BoxDecoration(
                                color: user.role.color.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.chipRadius),
                              ),
                              child: Text(
                                user.role.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: user.role.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            if (user.department != null &&
                                user.department!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceSM,
                                  vertical: AppTheme.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.chipRadius),
                                ),
                                child: Text(
                                  user.department!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      iconColor: Theme.of(context).colorScheme.outlineVariant,
                      itemBuilder: (context) => [
                        if (user.role != UserRole.admin) ...[
                          PopupMenuItem(
                            value: UserRole.student.name,
                            enabled: user.role != UserRole.student,
                            child: const Text('Create Student'),
                          ),
                          PopupMenuItem(
                            value: UserRole.lecturer.name,
                            enabled: user.role != UserRole.lecturer,
                            child: const Text('Create Lecturer'),
                          ),
                          const PopupMenuDivider(),
                        ],
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteUser(user);
                        } else {
                          _updateUserRole(user, value);
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
      ],
    );
  }
}
