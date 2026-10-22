import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme.dart';
import 'activities_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

/// Page principale après connexion : contenu + BottomNavigationBar (US#2).
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.login});

  final String login;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  /// Panier suivi en temps réel pour afficher le nombre d'activités sur l'onglet.
  late final _cart = cartRef(widget.login).snapshots();

  @override
  Widget build(BuildContext context) {
    final pages = [
      ActivitiesPage(login: widget.login),
      CartPage(login: widget.login),
      ProfilePage(login: widget.login),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: barShadow,
        ),
        child: StreamBuilder(
          stream: _cart,
          builder: (context, snapshot) {
            final count = snapshot.data?.size ?? 0;
            Widget cartIcon(IconData icon) => Badge(
              isLabelVisible: count > 0,
              backgroundColor: AppColors.coral,
              label: Text('$count'),
              child: Icon(icon),
            );

            return BottomNavigationBar(
              currentIndex: _index,
              onTap: (index) => setState(() => _index = index),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.local_activity_outlined),
                  activeIcon: Icon(Icons.local_activity),
                  label: 'Activités',
                ),
                BottomNavigationBarItem(
                  icon: cartIcon(Icons.shopping_basket_outlined),
                  activeIcon: cartIcon(Icons.shopping_basket),
                  label: 'Panier',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
