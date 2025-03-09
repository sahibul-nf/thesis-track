import 'package:flutter/material.dart';

class ResponsiveView extends StatelessWidget {
  const ResponsiveView(
      {super.key, required this.smallView, required this.largeView});
  final Widget smallView;
  final Widget largeView;

  @override
  Widget build(BuildContext context) {
    var isSmallScreen = MediaQuery.sizeOf(context).width < 1024;
    if (isSmallScreen) {
      return smallView;
    } else {
      return largeView;
    }
  }
}
