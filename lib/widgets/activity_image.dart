import 'dart:convert';

import 'package:flutter/material.dart';

/// Image d'une activité : URL (données de démo) ou base64 (activité ajoutée depuis l'app).
class ActivityImage extends StatelessWidget {
  const ActivityImage(this.image, {super.key, this.width, this.height});

  final String image;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_not_supported_outlined),
    );
    if (image.isEmpty) return fallback;

    Widget onError(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) => fallback;

    return image.startsWith('http')
        ? Image.network(
            image,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: onError,
          )
        : Image.memory(
            base64Decode(image),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: onError,
          );
  }
}
