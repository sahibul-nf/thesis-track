import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/loading.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _authController = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _selectedRole = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    await _authController.getAllUsers();
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
      await _authController.updateUserRole(
        userId: user.id,
        role: newRole,
      );
      await _loadUsers();
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
      await _authController.deleteUser(user.id);
      await _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'User Management',
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
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search users...',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
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
                        value: 'student',
                        label: Text('Students'),
                      ),
                      ButtonSegment(
                        value: 'lecturer',
                        label: Text('Lecturers'),
                      ),
                    ],
                    selected: {_selectedRole.value},
                    onSelectionChanged: (values) {
                      _selectedRole.value = values.first;
                    },
                  )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_authController.isLoading) {
              return const LoadingWidget();
            }

            final users = _authController.users.where((user) {
              final matchesSearch = user.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()) ||
                  user.email
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

              final matchesRole = _selectedRole.value == 'all' ||
                  user.role?.toLowerCase() == _selectedRole.value;

              return matchesSearch && matchesRole;
            }).toList();

            if (users.isEmpty) {
              return const EmptyStateWidget(
                message: 'No users found',
                icon: Icons.group_off_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name[0].toUpperCase()),
                      ),
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (user.role != null)
                                Chip(
                                  label: Text(user.role!.capitalize!),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              if (user.department.isNotEmpty)
                                Chip(
                                  label: Text(user.department),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          if (user.role != 'admin') ...[
                            PopupMenuItem(
                              value: 'student',
                              enabled: user.role != 'student',
                              child: const Text('Make Student'),
                            ),
                            PopupMenuItem(
                              value: 'lecturer',
                              enabled: user.role != 'lecturer',
                              child: const Text('Make Lecturer'),
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
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
