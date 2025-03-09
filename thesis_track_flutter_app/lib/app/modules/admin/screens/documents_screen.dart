import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Document Repository Empty',
      message:
          'All thesis files uploaded by students will be collected and displayed here.',
      icon: Iconsax.document,
      actionLabel: 'Refresh',
      actionIcon: Iconsax.refresh,
      onAction: () {},
      buttonSize: const Size(120, 45),
    );
  }
}
