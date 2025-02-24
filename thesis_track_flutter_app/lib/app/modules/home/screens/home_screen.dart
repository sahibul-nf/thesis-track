import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/loading.dart';
import 'package:thesis_track_flutter_app/app/widgets/text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _thesisController = Get.find<ThesisController>();
  final _authController = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadTheses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTheses() async {
    await _thesisController.getAllTheses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Thesis Track',
        showBackButton: false,
      ),
      body: PageLayout(
        compactLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
        mediumLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
        expandedLayout: TwoPaneLayout(
          fixedPaneChild: _buildSideMenu(),
          flexiblePaneChild: _buildContent(),
        ),
      ),
      floatingActionButton: RoleGuard.canCreateThesis()
          ? FloatingActionButton.extended(
              icon: const Icon(Iconsax.add),
              label: const Text('Submit Thesis'),
              onPressed: () => context.go('/thesis/create'),
            )
          : null,
    );
  }

  Widget _buildSideMenu() {
    final theme = Theme.of(context);
    final user = _authController.user;

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Profile Section
          Container(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.cardRadius),
                bottomRight: Radius.circular(AppTheme.cardRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  radius: 32,
                  child: Icon(
                    Iconsax.user,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: AppTheme.spaceMD),
                Text(
                  user?.name ?? 'User',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spaceXS),
                Text(
                  user?.role?.toUpperCase() ?? 'ROLE',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spaceMD),
              children: [
                _buildMenuItem(
                  icon: Iconsax.home,
                  title: 'Home',
                  isSelected: true,
                  onTap: () => context.go('/'),
                ),
                if (RoleGuard.canCreateThesis())
                  _buildMenuItem(
                    icon: Iconsax.add_square,
                    title: 'Submit Thesis',
                    onTap: () => context.go('/thesis/create'),
                  ),
                if (RoleGuard.canManageUsers())
                  _buildMenuItem(
                    icon: Iconsax.user_edit,
                    title: 'Manage Users',
                    onTap: () => context.go('/admin/users'),
                  ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child: OutlinedButton.icon(
              onPressed: () => _authController.logout(),
              icon: const Icon(Iconsax.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(AppTheme.spaceMD),
                side: BorderSide(color: theme.colorScheme.error),
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS,
      ),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spaceMD),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                SizedBox(width: AppTheme.spaceMD),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppTheme.spaceMD),
          child: ThesisSearchField(
            controller: _searchController,
            hint: 'Search theses...',
            onChanged: (value) => _searchQuery.value = value,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_thesisController.isLoading) {
              return const LoadingWidget();
            }

            final theses = _thesisController.theses;
            if (theses.isEmpty) {
              return EmptyStateWidget(
                message: 'No theses found',
                icon: Iconsax.book_1,
                actionLabel:
                    RoleGuard.canCreateThesis() ? 'Submit Thesis' : null,
                onAction: RoleGuard.canCreateThesis()
                    ? () => context.go('/thesis/create')
                    : null,
              );
            }

            final filteredTheses = theses.where((thesis) {
              final query = _searchQuery.value.toLowerCase();
              return thesis.title.toLowerCase().contains(query) ||
                  thesis.abstract.toLowerCase().contains(query) ||
                  thesis.researchField.toLowerCase().contains(query) ||
                  thesis.student.name.toLowerCase().contains(query);
            }).toList();

            if (filteredTheses.isEmpty) {
              return const EmptyStateWidget(
                message: 'No theses match your search',
                icon: Iconsax.search_normal,
              );
            }

            return RefreshIndicator(
              onRefresh: _loadTheses,
              child: ListView.builder(
                padding: EdgeInsets.all(AppTheme.spaceMD),
                itemCount: filteredTheses.length,
                itemBuilder: (context, index) {
                  return _buildThesisCard(filteredTheses[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildThesisCard(Thesis thesis) {
    final theme = Theme.of(context);

    return ThesisCard(
      onTap: () => context.go('/thesis/${thesis.id}'),
      margin: EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thesis.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppTheme.spaceXS),
                    Text(
                      thesis.student.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spaceMD),
              ThesisStatusChip(status: thesis.status),
            ],
          ),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            thesis.abstract,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              Icon(
                Iconsax.teacher,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: Text(
                  'Supervisors: ${thesis.supervisors.map((s) => s.name).join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (thesis.examiners.isNotEmpty) ...[
            SizedBox(height: AppTheme.spaceXS),
            Row(
              children: [
                Icon(
                  Iconsax.user_tick,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: Text(
                    'Examiners: ${thesis.examiners.map((e) => e.name).join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
