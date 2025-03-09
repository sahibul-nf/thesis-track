import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  const PopupMenu({
    super.key,
    required this.builder,
    this.alignmentOffset,
    required this.menuChildren,
    this.controller,
    this.style,
  });
  final Widget Function(BuildContext, MenuController, Widget?)? builder;
  final Offset? alignmentOffset;
  final List<Widget> menuChildren;
  final MenuController? controller;
  final MenuStyle? style;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: alignmentOffset,
      controller: controller,
      style: style,
      menuChildren: menuChildren,
      builder: builder,
    );
  }
}
