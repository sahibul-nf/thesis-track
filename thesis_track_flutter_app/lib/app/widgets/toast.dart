import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcnui;

class MyToast {
  /// Comming soon toast
  static void showComingSoonToast(BuildContext context) {
    // toastification.show(
    //   context: context, // optional if you use ToastificationWrapper
    //   type: ToastificationType.info,
    //   style: ToastificationStyle.flat,
    //   alignment: Alignment.bottomCenter,
    //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //   backgroundColor: Theme.of(context).colorScheme.errorContainer,
    //   foregroundColor: Theme.of(context).colorScheme.error,
    //   primaryColor: Theme.of(context).colorScheme.error,
    //   borderSide: BorderSide.none,
    //   title: const Text(
    //     'Coming soon!',
    //     style: TextStyle(
    //       fontSize: 12,
    //     ),
    //   ),
    //   description: const Text(
    //     'This feature is not available yet.',
    //     style: TextStyle(
    //       fontSize: 12,
    //     ),
    //   ),
    //   showProgressBar: false,
    //   closeOnClick: true,
    //   closeButtonShowType: CloseButtonShowType.none,
    //   autoCloseDuration: const Duration(seconds: 4),
    // );

    showShadcnUIToast(
      context,
      'Coming soon!',
      'This feature is not available yet.',
      isError: true,
    );
  }

  static void showShadcnUIToast(
    BuildContext context,
    String title,
    String message, {
    shadcnui.ToastLocation location = shadcnui.ToastLocation.bottomRight,
    bool isError = false,
  }) {
    shadcnui.showToast(
      context: context,
      location: location,
      builder: (context, overlay) {
        return _buildToast(context, overlay, isError, title, message);
      },
    );
  }

  static Widget _buildToast(
    BuildContext context,
    shadcnui.ToastOverlay overlay,
    bool isError,
    String title,
    String message,
  ) {
    return shadcnui.SurfaceCard(
      fillColor:
          isError ? shadcnui.Theme.of(context).colorScheme.destructive : null,
      borderColor:
          isError ? shadcnui.Theme.of(context).colorScheme.destructive : null,
      filled: isError,
      child: shadcnui.Basic(
        title: Text(
          title,
          style: TextStyle(
            color: isError
                ? shadcnui.Theme.of(context).colorScheme.destructiveForeground
                : null,
          ),
        ),
        titleSpacing: 8,
        content: Text(
          message,
          style: TextStyle(
            color: isError
                ? shadcnui.Theme.of(context).colorScheme.destructiveForeground
                : null,
          ),
        ).xSmall().muted(),
        trailing: shadcnui.Button(
          style: isError
              ? const shadcnui.ButtonStyle.secondaryIcon(
                  size: shadcnui.ButtonSize.xSmall,
                )
              : const shadcnui.ButtonStyle.primary(
                  size: shadcnui.ButtonSize.small,
                ),
          onPressed: () {
            overlay.close();
          },
          child: isError ? const Icon(Icons.close) : const Text('Close'),
        ),
        // trailingAlignment: Alignment.center,
      ),
    );
  }
}
