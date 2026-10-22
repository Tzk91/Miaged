import 'package:flutter/material.dart';

/// Icône associée à chaque catégorie d'activité.
IconData categoryIcon(String category) => switch (category) {
  'Sport' => Icons.directions_run,
  'Shopping' => Icons.shopping_bag_outlined,
  'Gastronomie' => Icons.restaurant,
  'Culture' => Icons.museum_outlined,
  'Nature' => Icons.landscape_outlined,
  _ => Icons.category_outlined,
};

/// Pastille de catégorie, lisible aussi posée sur une photo.
class CategoryChip extends StatelessWidget {
  const CategoryChip(this.category, {super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryIcon(category), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            category.isEmpty ? 'Autre' : category,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
