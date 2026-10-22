import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      ActivitiesPage(login: widget.login),
      CartPage(login: widget.login),
      ProfilePage(login: widget.login),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_activity), label: 'Activités'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
