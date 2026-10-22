import 'package:flutter_test/flutter_test.dart';
import 'package:miaged/models/activity.dart';
import 'package:miaged/services/image_classifier.dart';

void main() {
  test('Activity : toMap puis fromMap redonne la même activité', () {
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

  test('Activity.fromMap tolère un prix décimal et des champs manquants', () {
    final activity = Activity.fromMap('x', {'price': 12.0});

    expect(activity.price, 12);
    expect(activity.title, '');
    expect(activity.maxPeople, 0);
  });

  test('categoryFor retient la première étiquette ML Kit connue', () {
    expect(categoryFor(['Person', 'Kayak', 'Food']), 'Sport');
    expect(categoryFor(['Pizza']), 'Gastronomie');
    expect(categoryFor(['Museum']), 'Culture');
    expect(categoryFor(['Handbag']), 'Shopping');
    expect(categoryFor(['Lake']), 'Nature');
    expect(categoryFor(['Person']), 'Autre');
  });
}
