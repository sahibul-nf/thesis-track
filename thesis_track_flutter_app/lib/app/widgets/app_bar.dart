import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/custom_menu_item.dart';
import 'package:thesis_track_flutter_app/app/widgets/popup_menu.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';

class ThesisAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showLogoutButton;

  const ThesisAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showLogoutButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      forceMaterialTransparency: true,
      toolbarHeight: 70,
      title: Text(title),
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            )
          : null,
      actions: [
        if (actions != null) ...[
          ...actions!,
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 30,
            ),
            child: const VerticalDivider(
              width: 1,
            ).withPadding(horizontal: AppTheme.spaceMD),
          ),
        ],
        if (showLogoutButton)
          // Avatar
          Flexible(
            child: Obx(() {
              var user = AuthController.to.user;
              var initials = sha.Avatar.getInitials(user?.name ?? 'John Doe');

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
                      backgroundColor: theme.colorScheme.primaryContainer,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            sha.Avatar(
                              initials: sha.Avatar.getInitials(initials),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              size: 40,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'John Doe',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
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
                          ],
                        ),
                        const Divider(),
                        // Profile settings
                        CustomMenuItem(
                          title: 'Profile settings',
                          leading: const Icon(Iconsax.user, size: 16),
                          onTap: () {
                            MyToast.showComingSoonToast(context);
                          },
                          shortcut: null,
                        ),
                        // Sign out
                        Obx(() {
                          bool isLoading = AuthController.to.isLoading;
                          return CustomMenuItem(
                            title: 'Sign out',
                            leading: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.grey,
                                    strokeWidth: 2,
                                  )
                                : const Icon(Iconsax.logout, size: 16),
                            onTap: isLoading
                                ? null
                                : () async {
                                    String? err =
                                        await AuthController.to.logout();
                                    return MyToast.showShadcnUIToast(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      'Sign out failed',
                                      err ?? 'Unknown error',
                                      isError: true,
                                    );

                                    // show success toast
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            // spacing: 2,
            children: [
              Text(
                user?.name ?? 'John Doe',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                user?.role.name ?? 'Student',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          );
        }),
        sha.Gap(AppTheme.spaceLG),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
