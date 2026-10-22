import 'package:flutter/material.dart';

import '../theme.dart';
import 'centered_body.dart';

/// Barre d'actions fixée en bas de page (détail d'une activité, ajout d'une activité).
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: barShadow,
      ),
      child: SafeArea(
        child: CenteredBody(
          maxWidth: 720,
          shrinkWrap: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: child,
          ),
        ),
      ),
    );
  }
}
