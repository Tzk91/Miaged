import 'package:flutter/material.dart';

/// Limite la largeur du contenu et le centre : lisible sur téléphone comme sur tablette.
class CenteredBody extends StatelessWidget {
  const CenteredBody({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.shrinkWrap = false,
  });

  final Widget child;
  final double maxWidth;

  /// À activer hors du corps de page (barre du bas…) : la hauteur suit alors le contenu.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: shrinkWrap ? 1 : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
