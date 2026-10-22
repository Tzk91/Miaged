import 'package:flutter_test/flutter_test.dart';
import 'package:miaged/models/activity.dart';
import 'package:miaged/services/image_classifier.dart';

void main() {
  group('Activity', () {
    test('toMap puis fromMap redonne la même activité', () {
      const activity = Activity(
        title: 'Kayak de mer',
        category: 'Sport',
        location: 'Villefranche-sur-Mer',
        price: 35,
        maxPeople: 10,
        image: 'https://example.com/kayak.jpg',
      );

      final copy = Activity.fromMap('kayak', activity.toMap());

      expect(copy.id, 'kayak');
      expect(copy.toMap(), activity.toMap());
      expect(copy.priceLabel, '35 €');
    });

    test('fromMap tolère un prix décimal et des champs manquants', () {
      final activity = Activity.fromMap('x', {'price': 12.0});

      expect(activity.price, 12);
      expect(activity.title, '');
      expect(activity.maxPeople, 0);
    });
  });

  group('categoryFor (IA)', () {
    test('ignore les étiquettes sans catégorie', () {
      expect(categoryFor([('Person', 0.95), ('Kayak', 0.8)]), 'Sport');
    });

    test('additionne les confiances par catégorie', () {
      // Gastronomie : 0.6 + 0.55 = 1.15 > Culture : 0.9
      final labels = [('Statue', 0.9), ('Food', 0.6), ('Bread', 0.55)];
      expect(categoryFor(labels), 'Gastronomie');
    });

    test('une étiquette forte l\'emporte sur une plus faible', () {
      expect(categoryFor([('Lake', 0.6), ('Kayak', 0.9)]), 'Sport');
      expect(categoryFor([('Handbag', 0.7)]), 'Shopping');
      expect(categoryFor([('Museum', 0.8)]), 'Culture');
      expect(categoryFor([('Mountain', 0.85)]), 'Nature');
    });

    test('« Autre » si rien n\'est reconnu', () {
      expect(categoryFor([]), 'Autre');
      expect(categoryFor([('Person', 0.9), ('Sky', 0.9)]), 'Autre');
    });
  });
}
