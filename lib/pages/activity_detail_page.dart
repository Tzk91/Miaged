import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../widgets/activity_image.dart';

/// US#3 : détail d'une activité, avec ajout au panier de l'utilisateur.
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key, required this.activity, required this.login});

  final Activity activity;
  final String login;

  Future<void> _addToCart(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // L'id de l'activité sert d'id dans le panier : une même activité n'y figure qu'une fois.
      await cartRef(login).doc(activity.id).set(activity.toMap());
      messenger.showSnackBar(SnackBar(content: Text('${activity.title} ajouté au panier')));
    } catch (e) {
      debugPrint('Ajout au panier impossible : $e');
      messenger.showSnackBar(const SnackBar(content: Text("Impossible d'ajouter au panier")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(activity.title)),
      body: ListView(
        children: [
          ActivityImage(activity.image, width: double.infinity, height: 240),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Chip(avatar: const Icon(Icons.label_outline), label: Text(activity.category)),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(activity.location),
                ),
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: Text('${activity.maxPeople} personnes maximum'),
                ),
                ListTile(
                  leading: const Icon(Icons.euro),
                  title: Text(activity.priceLabel, style: textTheme.titleLarge),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => _addToCart(context),
                  child: const Text('Ajouter au panier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
