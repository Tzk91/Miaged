import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../widgets/activity_image.dart';
import 'activity_detail_page.dart';

/// US#2 : liste de toutes les activités, lue en temps réel dans Firestore.
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

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ActivityImage(activity.image, width: 56, height: 56),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(activity.location),
                  trailing: Text(
                    activity.priceLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ActivityDetailPage(activity: activity, login: login),
                  )),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
