import 'package:cloud_firestore/cloud_firestore.dart';

/// Collections Firestore de l'application.
final _db = FirebaseFirestore.instance;

/// Un document par utilisateur, dont l'identifiant est le login.
final usersRef = _db.collection('users');

final activitiesRef = _db.collection('activities');

/// Panier d'un utilisateur : sous-collection de son document, une activité par document.
CollectionReference<Map<String, dynamic>> cartRef(String login) =>
    usersRef.doc(login).collection('cart');
