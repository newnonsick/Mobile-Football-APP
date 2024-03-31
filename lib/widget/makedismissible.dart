import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MakeDismissible extends StatelessWidget {
  final Widget child;
  const MakeDismissible({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}