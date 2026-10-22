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

/// Couleur associée à chaque catégorie : même repère dans la liste, le détail et l'ajout.
Color categoryColor(String category) => switch (category) {
  'Sport' => const Color(0xFF2F7BEA),
  'Shopping' => const Color(0xFFD9467A),
  'Gastronomie' => const Color(0xFFE08600),
  'Culture' => const Color(0xFF7B5CF0),
  'Nature' => const Color(0xFF23985A),
  _ => const Color(0xFF64748B),
};

/// Pastille de catégorie, lisible aussi posée sur une photo.
class CategoryChip extends StatelessWidget {
  const CategoryChip(this.category, {super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: categoryColor(category),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryIcon(category), size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            category.isEmpty ? 'Autre' : category,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
