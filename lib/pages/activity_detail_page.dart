import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_image.dart';
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
            expandedHeight: 300,
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
                        end: Alignment.center,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CenteredBody(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryChip(activity.category),
                    const SizedBox(height: 12),
                    Text(
                      activity.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Column(
                        children: [
                          _InfoTile(
                            icon: Icons.place_outlined,
                            label: 'Lieu',
                            value: activity.location,
                          ),
                          const Divider(height: 1),
                          _InfoTile(
                            icon: Icons.group_outlined,
                            label: 'Participants',
                            value: '${activity.maxPeople} personnes maximum',
                          ),
                          const Divider(height: 1),
                          _InfoTile(
                            icon: Icons.euro,
                            label: 'Prix',
                            value: activity.priceLabel,
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: CenteredBody(
          shrinkWrap: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                  ),
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
        ),
      ),
    );
  }
}

/// Ligne d'information du détail : icône, intitulé et valeur.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Icon(icon),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: highlight
            ? theme.textTheme.titleLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              )
            : theme.textTheme.titleMedium,
      ),
    );
  }
}
