import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../theme.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_image.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/centered_body.dart';

/// US#3 : détail d'une activité, avec ajout au panier de l'utilisateur.
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({
    super.key,
    required this.activity,
    required this.login,
  });

  final Activity activity;
  final String login;

  Future<void> _addToCart(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // L'id de l'activité sert d'id dans le panier : une même activité n'y figure qu'une fois.
      await cartRef(login).doc(activity.id).set(activity.toMap());
      messenger.showSnackBar(
        SnackBar(content: Text('${activity.title} ajouté au panier')),
      );
    } catch (e) {
      debugPrint('Ajout au panier impossible : $e');
      messenger.showSnackBar(
        const SnackBar(content: Text("Impossible d'ajouter au panier")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            titleTextStyle: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            title: Text(activity.title),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: activityHeroTag(activity),
                    child: ActivityImage(activity.image),
                  ),
                  // Dégradé pour garder le titre et la flèche lisibles sur la photo.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.4],
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Haut arrondi du contenu, posé sur le bas de la photo.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CenteredBody(
              maxWidth: 720,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryChip(activity.category),
                    const SizedBox(height: 14),
                    Text(
                      activity.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoTile(
                      icon: Icons.place_outlined,
                      label: 'Lieu',
                      value: activity.location,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.group_outlined,
                            label: 'Participants',
                            value: '${activity.maxPeople} max',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.euro,
                            label: 'Prix',
                            value: activity.priceLabel,
                            color: AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _addToCart(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ajouter au panier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Information du détail : pastille d'icône, intitulé et valeur.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.teal,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
