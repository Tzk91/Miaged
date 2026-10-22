import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../theme.dart';
import 'activity_image.dart';
import 'category_chip.dart';

/// Tag partagé par la carte et la page de détail : la photo « s'envole » vers le détail.
String activityHeroTag(Activity activity) => 'activity-image-${activity.id}';

/// Carte d'une activité dans la liste : photo pleine carte, catégorie, prix,
/// titre et lieu écrits sur la photo.
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, required this.onTap});

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPhoto = Colors.white.withValues(alpha: 0.85);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow,
      ),
      child: Material(
        // Teinte visible le temps que la photo se charge.
        color: AppColors.line,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: activityHeroTag(activity),
              child: ActivityImage(activity.image),
            ),
            // Dégradé sombre en bas : le texte reste lisible sur n'importe quelle photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                  colors: [Colors.transparent, Color(0xD90B1C2A)],
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: CategoryChip(activity.category),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activity.priceLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 16, color: onPhoto),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onPhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Au-dessus de la photo, pour que l'effet d'appui reste visible.
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
