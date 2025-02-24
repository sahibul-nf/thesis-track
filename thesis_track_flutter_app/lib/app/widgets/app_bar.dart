import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';

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

    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            )
          : null,
      actions: [
        if (showLogoutButton)
          PopupMenuButton<void>(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(
                enabled: false,
                child: Text(authController.user?.name ?? ''),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                child: const Text('Logout'),
                onTap: () => authController.logout(),
              ),
            ],
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
