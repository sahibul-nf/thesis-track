import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class CustomMenuItem extends StatelessWidget {
  const CustomMenuItem({
    super.key,
    required this.title,
    this.shortcut = '',
    required this.onTap,
    this.leading,
  });
  final Widget? leading;
  final String title;
  final String? shortcut;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading?.paddingOnly(right: 10),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 0,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      visualDensity: const VisualDensity(
        horizontal: 0,
        vertical: -4,
      ),
      dense: true,
      horizontalTitleGap: 0,
      minVerticalPadding: 0,
      trailing: Text(
        shortcut ?? '',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w300,
        ),
      ),
      onTap: onTap,
    );
  }
}
