import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../widgets/activity_card.dart';
import 'activity_detail_page.dart';

/// US#2 : toutes les activités, lues en temps réel dans Firestore.
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key, required this.login});

  final String login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activités')),
      body: StreamBuilder(
        stream: activitiesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = snapshot.data!.docs
              .map((doc) => Activity.fromMap(doc.id, doc.data()))
              .toList();
          if (activities.isEmpty) {
            return const Center(child: Text('Aucune activité pour le moment'));
          }

          // Une colonne sur téléphone, plusieurs sur tablette.
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 480,
              mainAxisExtent: 280,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ActivityCard(
                activity: activity,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ActivityDetailPage(activity: activity, login: login),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
