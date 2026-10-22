import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Catégories proposées et étiquettes du modèle de base ML Kit qui y mènent
/// (liste complète : https://developers.google.com/ml-kit/vision/image-labeling/label-map).
/// Les étiquettes trop générales (« Sky », « Rock », « Plant »…), présentes sur
/// presque toutes les photos d'extérieur, sont volontairement absentes.
const _labelsByCategory = {
  'Sport': [
    'Sports',
    'Team',
    'Competition',
    'Stadium',
    'Pitch',
    'Jersey',
    'Soccer',
    'Rugby',
    'Polo',
    'Softball',
    'Badminton',
    'Archery',
    'Gymnastics',
    'Boxer',
    'Running',
    'Marathon',
    'Track',
    'Race',
    'Racing',
    'Bicycle',
    'Cycling',
    'Unicycle',
    'Skateboard',
    'Skateboarder',
    'Longboard',
    'Skiing',
    'Snowboarding',
    'Sled',
    'Sledding',
    'Curling',
    'Kayak',
    'Canoe',
    'Rafting',
    'Rowing',
    'Swimming',
    'Pool',
    'Surfing',
    'Surfboard',
    'Windsurfing',
    'Wakeboarding',
    'Waterskiing',
    'Tubing',
    'Scuba diving',
    'Snorkeling',
    'Wetsuit',
    'Helmet',
    'Muscle',
  ],
  'Shopping': [
    'Product',
    'Bag',
    'Handbag',
    'Shoe',
    'Sneakers',
    'Dress',
    'Gown',
    'Jeans',
    'Denim',
    'Jacket',
    'Outerwear',
    'Blazer',
    'Leggings',
    'Shorts',
    'Hat',
    'Cap',
    'Beanie',
    'Scarf',
    'Tie',
    'Sunglasses',
    'Lipstick',
    'Jewellery',
    'Necklace',
    'Bracelet',
    'Bangle',
    'Ring',
    'Leather',
    'Textile',
    'Money',
    'Receipt',
    'Toy',
    'Stuffed toy',
    'Plush',
    'Lego',
  ],
  'Gastronomie': [
    'Food',
    'Cuisine',
    'Meal',
    'Lunch',
    'Supper',
    'Eating',
    'Fast food',
    'Cheeseburger',
    'Hot dog',
    'Pizza',
    'Sushi',
    'Bento',
    'Pho',
    'Couscous',
    'Pasteles',
    'Bread',
    'Cake',
    'Pie',
    'Cookie',
    'Icing',
    'Gelato',
    'Fruit',
    'Vegetable',
    'Juice',
    'Coffee',
    'Cappuccino',
    'Cola',
    'Wine',
    'Alcohol',
    'Bar',
    'Menu',
    'Cutlery',
    'Tableware',
    'Cup',
    'Cookware and bakeware',
    'Kitchen',
    'Steaming',
  ],
  'Culture': [
    'Museum',
    'Monument',
    'Statue',
    'Ruins',
    'Palace',
    'Castle',
    'Tower',
    'Church',
    'Cathedral',
    'Mosque',
    'Temple',
    'Porcelain',
    'Watercolor paint',
    'Poster',
    'Comics',
    'Concert',
    'Musical',
    'Musical instrument',
    'Piano',
    'Musician',
    'Singer',
    'Song',
    'Pop music',
    'Deejay',
    'Dance',
    'Carnival',
    'Circus',
  ],
  'Nature': [
    'Mountain',
    'Forest',
    'Jungle',
    'Lake',
    'River',
    'Waterfall',
    'Beach',
    'Cliff',
    'Canyon',
    'Cave',
    'Caving',
    'Glacier',
    'Iceberg',
    'Volcano',
    'Desert',
    'Dune',
    'Prairie',
    'Field',
    'Swamp',
    'Reef',
    'Underwater',
    'Sunset',
    'Aurora',
    'Park',
    'Garden',
    'Flower',
    'Bird',
    'Horse',
    'Safari',
    'Camping',
    'Backpacking',
  ],
};

/// Index inverse : étiquette ML Kit → catégorie.
final _categoryOfLabel = {
  for (final entry in _labelsByCategory.entries)
    for (final label in entry.value) label: entry.key,
};

/// Résultat de l'analyse d'une image.
class Classification {
  const Classification(this.category, this.labels);

  final String category;

  /// Étiquettes reconnues par ML Kit avec leur confiance (0 à 1), de la plus sûre à la moins sûre.
  final List<(String, double)> labels;
}

/// Choisit la catégorie dont les étiquettes reconnues cumulent la plus forte confiance,
/// « Autre » si aucune étiquette ne correspond à une catégorie.
///
/// Additionner les confiances rend le choix plus robuste qu'une seule étiquette :
/// une photo de repas reconnue « Food », « Cuisine » et « Tableware » l'emporte
/// sur un « Statue » isolé en arrière-plan.
String categoryFor(List<(String, double)> labels) {
  final scores = <String, double>{};
  for (final (label, confidence) in labels) {
    final category = _categoryOfLabel[label];
    if (category != null) {
      scores[category] = (scores[category] ?? 0) + confidence;
    }
  }
  if (scores.isEmpty) return 'Autre';
  return scores.entries
      .reduce((best, entry) => entry.value > best.value ? entry : best)
      .key;
}

/// Analyse une image avec ML Kit Image Labeling (modèle embarqué, exécuté sur le
/// téléphone, sans connexion ni clé d'API) et en déduit sa catégorie.
Future<Classification> classifyImage(String path) async {
  // shortcut: ML Kit n'existe que sur Android/iOS ; sur le web la catégorie reste « Autre ».
  if (kIsWeb) return const Classification('Autre', []);

  final labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );
  try {
    final found = await labeler.processImage(InputImage.fromFilePath(path));
    final labels = [for (final label in found) (label.label, label.confidence)]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final category = categoryFor(labels);
    debugPrint(
      'ML Kit : ${labels.map((l) => '${l.$1} ${l.$2.toStringAsFixed(2)}').join(', ')}'
      ' → $category',
    );
    return Classification(category, labels);
  } finally {
    await labeler.close();
  }
}
