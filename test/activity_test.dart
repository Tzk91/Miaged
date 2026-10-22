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

  // Résultats réels de MobileNet (TensorFlow.js) sur les photos de démo de tool/seed.json.
  group('categoryForImageNet (IA web)', () {
    test('kayak et plongée → Sport', () {
      expect(
        categoryForImageNet([('canoe', 0.61), ('paddle, boat paddle', 0.34)]),
        'Sport',
      );
      expect(
        categoryForImageNet([('scuba diver', 0.67), ('snorkel', 0.20)]),
        'Sport',
      );
    });

    test('socca → Gastronomie (« skillet » n\'est pas « ski »)', () {
      final labels = [
        ('dough', 0.41),
        ('frying pan, frypan, skillet', 0.33),
        ('bagel, beigel', 0.06),
      ];
      expect(categoryForImageNet(labels), 'Gastronomie');
    });

    test('lac d\'Allos → Nature malgré un château en arrière-plan', () {
      final labels = [
        ('lakeside, lakeshore', 0.54),
        ('valley, vale', 0.21),
        ('alp', 0.16),
        ('castle', 0.04),
      ];
      expect(categoryForImageNet(labels), 'Nature');
    });

    test('musée → Culture, sacs et marché → Shopping', () {
      expect(
        categoryForImageNet([('palace', 0.76), ('monastery', 0.13)]),
        'Culture',
      );
      expect(
        categoryForImageNet([('plastic bag', 0.91), ('mountain tent', 0.03)]),
        'Shopping',
      );
      final market = [
        ('grocery store, grocery, food market, market', 0.20),
        ('restaurant, eating house, eating place, eatery', 0.14),
      ];
      expect(categoryForImageNet(market), 'Shopping');
    });

    test('« Autre » si aucune classe connue', () {
      expect(categoryForImageNet([('jellyfish', 0.8)]), 'Autre');
    });
  });
}
