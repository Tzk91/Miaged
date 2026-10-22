import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../widgets/activity_image.dart';

/// US#4 : panier de l'utilisateur, avec total et retrait d'une activité.
class CartPage extends StatelessWidget {
  const CartPage({super.key, required this.login});

  final String login;

  @override
  Widget build(BuildContext context) {
    final cart = cartRef(login);

    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
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
          if (items.isEmpty) {
            return const Center(child: Text('Votre panier est vide'));
          }
          final total = items.fold<int>(0, (sum, activity) => sum + activity.price);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final activity = items[index];
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ActivityImage(activity.image, width: 56, height: 56),
                        ),
                        title: Text(activity.title),
                        subtitle: Text('${activity.location} · ${activity.priceLabel}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Retirer du panier',
                          onPressed: () => cart.doc(activity.id).delete(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: ListTile(
                  title: Text('Total', style: Theme.of(context).textTheme.titleLarge),
                  trailing: Text('$total €', style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
