import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/custom_menu_item.dart';
import 'package:thesis_track_flutter_app/app/widgets/popup_menu.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';

import 'routes/app_routes.dart';

class MainView extends StatefulWidget {
  const MainView({super.key, required this.child});
  final Widget child;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final _thesisController = Get.find<ThesisController>();
  final _authController = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final selectedIndex = 0.obs;
  final pageTitle = ''.obs;

  void _initializeSelectedIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = GoRouterState.of(context);
      final routes = _getRoutes();
      final index = routes.indexOf(currentRoute.uri.path);
      if (index != -1) {
        selectedIndex.value = index;
        pageTitle.value = _getFormattedPageTitle(routes[index]);
      }
    });
  }

  String _getThesisScreenTitle(UserRole role) {
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

  String _getFormattedPageTitle(String route) {
    // Convert route path to readable title
    return switch (route) {
      RouteLocation.home => 'Home',
      RouteLocation.userManagement => 'User Management',
      RouteLocation.myThesis => 'My Thesis',
      RouteLocation.thesis =>
        _getThesisScreenTitle(AuthController.to.user?.role ?? UserRole.student),
      RouteLocation.topProgress => 'Top Progress',
      RouteLocation.documents => 'Documents',
      _ => route,
    };
  }

  List<String> _getRoutes() {
    final userRole = AuthController.to.user?.role;
    return [
      RouteLocation.home,
      if (userRole == UserRole.admin) RouteLocation.userManagement,
      if (userRole != UserRole.admin) RouteLocation.myThesis,
      RouteLocation.thesis,
      RouteLocation.topProgress,
      if (userRole == UserRole.admin) RouteLocation.documents,
    ];
  }

  List<NavigationDrawerDestination> _getNavigationDestinations() {
    final userRole = AuthController.to.user?.role;
    return [
      const NavigationDrawerDestination(
        label: Text('Home'),
        icon: Icon(Iconsax.home),
        selectedIcon: Icon(Iconsax.home),
      ),
      if (userRole == UserRole.admin)
        const NavigationDrawerDestination(
          label: Text('Users'),
          icon: Icon(Iconsax.user),
          selectedIcon: Icon(Iconsax.user),
        ),
      if (userRole != UserRole.admin)
        const NavigationDrawerDestination(
        label: Text(
          'My Thesis'
        ),
          icon: Icon(Iconsax.document_text),
          selectedIcon: Icon(Iconsax.document_text),
        ),
      const NavigationDrawerDestination(
        label: Text('Theses'),
        icon: Icon(Iconsax.document_text_1),
        selectedIcon: Icon(Iconsax.document_text_1),
      ),
      const NavigationDrawerDestination(
        label: Text('Top Progress'),
        icon: Icon(Iconsax.ranking_1),
        selectedIcon: Icon(Iconsax.ranking_1),
      ),
      if (userRole == UserRole.admin)
        const NavigationDrawerDestination(
          label: Text('Documents'),
          icon: Icon(Iconsax.document_cloud),
          selectedIcon: Icon(Iconsax.document_cloud),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationDrawerDestinations = _getNavigationDestinations();
    final routes = _getRoutes();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  /// Logo
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSM,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSM,
                      vertical: AppTheme.spaceMD,
                    ),
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 45,
                        ),
                        Text(
                          'ThesisTrack',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Navigation Drawer
                  Flexible(
                    child: NavigationDrawer(
                      backgroundColor: theme.colorScheme.surface,
                      indicatorColor:
                          theme.colorScheme.primary.withOpacity(0.05),
                      selectedIndex: selectedIndex.value,
                      onDestinationSelected: (index) {
                        if (index < routes.length) {
                          final targetRoute = routes[index];
                          if (targetRoute.isNotEmpty) {
                            selectedIndex.value = index;
                            pageTitle.value =
                                _getFormattedPageTitle(targetRoute);
                            context.go(targetRoute);
                          }
                        }
                      },
                      children: navigationDrawerDestinations,
                    ),
                  ),
                ],
              ),
            );
          }),
          const VerticalDivider(width: 1),
          Expanded(
            child: NestedScrollView(
              physics: const NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, innerBoxScrolled) {
                return [
                  SliverAppBar(
                    surfaceTintColor: theme.colorScheme.surfaceBright,
                    centerTitle: false,
                    toolbarHeight: 70,
                    title: Obx(() {
                      return Text(
                        pageTitle.value,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ).withPadding(horizontal: AppTheme.spaceSM);
                    }),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.notification, size: 18),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 30,
                        ),
                        child: const VerticalDivider(
                          width: 1,
                        ).withPadding(horizontal: AppTheme.spaceMD),
                      ),
                      // Avatar
                      Flexible(
                        child: Obx(() {
                          var user = AuthController.to.user;
                          var initials =
                              sha.Avatar.getInitials(user?.name ?? 'John Doe');

                          return PopupMenu(
                            alignmentOffset: const Offset(-120, 5),
                            style: const MenuStyle(
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 16,
                                ),
                              ),
                              elevation: WidgetStatePropertyAll(10),
                            ),
                            builder: (context, ctrl, c) {
                              return InkWell(
                                onTap: () {
                                  ctrl.isOpen ? ctrl.close() : ctrl.open();
                                },
                                borderRadius: BorderRadius.circular(36),
                                child: sha.Avatar(
                                  initials: sha.Avatar.getInitials(initials),
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  size: 36,
                                ),
                              );
                            },
                            menuChildren: [
                              SizedBox(
                                width: 200,
                                child: Column(
                                  children: [
                                    Row(
                                      spacing: 8,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        sha.Avatar(
                                          initials:
                                              sha.Avatar.getInitials(initials),
                                          backgroundColor: theme
                                              .colorScheme.primaryContainer,
                                          size: 40,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?.name ?? 'John Doe',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            Text(
                                              user?.role.name ?? 'Student',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    // Profile settings
                                    CustomMenuItem(
                                      title: 'Profile settings',
                                      leading:
                                          const Icon(Iconsax.user, size: 16),
                                      onTap: () {
                                        MyToast.showComingSoonToast(context);
                                      },
                                      shortcut: null,
                                    ),
                                    // Sign out
                                    Obx(() {
                                      bool isLoading =
                                          AuthController.to.isLoading;
                                      return CustomMenuItem(
                                        title: 'Sign out',
                                        leading: isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.grey,
                                                strokeWidth: 2,
                                              )
                                            : const Icon(Iconsax.logout,
                                                size: 16),
                                        onTap: isLoading
                                            ? null
                                            : () async {
                                                String? err =
                                                    await AuthController.to
                                                        .logout();
                                                if (err != null) {
                                                  return MyToast
                                                      .showShadcnUIToast(
                                                    context,
                                                    'Sign out failed',
                                                    err,
                                                    isError: true,
                                                  );
                                                }

                                                MyToast.showShadcnUIToast(
                                                  context,
                                                  'Sign out successful',
                                                  'You have been signed out',
                                                  isError: false,
                                                );

                                                context.go(RouteLocation.login);
                                              },
                                        shortcut: null,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ).asSkeleton(enabled: AuthController.to.isLoading);
                        }),
                      ),
                      const sha.Gap(10),
                      Obx(() {
                        var user = AuthController.to.user;
                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 120,
                            minWidth: 48,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user?.name ?? 'John Doe',
                                maxLines: 1,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                user?.role.name ?? 'Student',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      sha.Gap(AppTheme.spaceLG),
                    ],
                  ),
                ];
              },
              body: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
