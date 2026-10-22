import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../theme.dart';
import '../widgets/activity_image.dart';
import '../widgets/centered_body.dart';

/// US#4 : panier de l'utilisateur, avec total et retrait d'une activité.
class CartPage extends StatelessWidget {
  const CartPage({super.key, required this.login});

  final String login;

  @override
  Widget build(BuildContext context) {
    final cart = cartRef(login);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: StreamBuilder(
        stream: cart.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!.docs
              .map((doc) => Activity.fromMap(doc.id, doc.data()))
              .toList();
          if (items.isEmpty) return const _EmptyCart();
          final total = items.fold<int>(
            0,
            (sum, activity) => sum + activity.price,
          );

          return Column(
            children: [
              Expanded(
                child: CenteredBody(
                  maxWidth: 720,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final activity = items[index];
                      return _CartItem(
                        activity: activity,
                        onRemove: () => cart.doc(activity.id).delete(),
                      );
                    },
                  ),
                ),
              ),
              _TotalBar(count: items.length, total: total),
            ],
          );
        },
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({required this.activity, required this.onRemove});

  final Activity activity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ActivityImage(activity.image, width: 88, height: 88),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 14, color: muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.priceLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Retirer du panier',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.sand,
                foregroundColor: AppColors.ink,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// Total du panier, en bas de l'écran.
class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: CenteredBody(
          maxWidth: 720,
          shrinkWrap: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      count > 1 ? '$count activités' : '$count activité',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '$total €',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 54,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Votre panier est vide',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Ajoutez des activités depuis l'onglet Activités",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
