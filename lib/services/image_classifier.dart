import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Catégories proposées et étiquettes du modèle de base ML Kit qui y mènent
/// (liste complète : https://developers.google.com/ml-kit/vision/image-labeling/label-map).
const _labelsByCategory = {
  'Sport': [
    'Sports', 'Team', 'Competition', 'Stadium', 'Pitch', 'Jersey', 'Soccer',
    'Rugby', 'Polo', 'Softball', 'Badminton', 'Archery', 'Gymnastics',
    'Boxer', 'Running', 'Marathon', 'Track', 'Race', 'Racing', 'Bicycle',
    'Cycling', 'Unicycle', 'Skateboard', 'Skateboarder', 'Longboard',
    'Skiing', 'Snowboarding', 'Sled', 'Sledding', 'Curling', 'Kayak', 'Canoe',
    'Rafting', 'Rowing', 'Swimming', 'Pool', 'Surfing', 'Surfboard',
    'Windsurfing', 'Wakeboarding', 'Waterskiing', 'Tubing', 'Scuba diving',
    'Snorkeling', 'Wetsuit', 'Helmet', 'Muscle',
  ],
  'Shopping': [
    'Product', 'Bag', 'Handbag', 'Shoe', 'Sneakers', 'Dress', 'Gown',
    'Jeans', 'Denim', 'Jacket', 'Outerwear', 'Blazer', 'Leggings', 'Shorts',
    'Hat', 'Cap', 'Beanie', 'Scarf', 'Tie', 'Sunglasses', 'Lipstick',
    'Jewellery', 'Necklace', 'Bracelet', 'Bangle', 'Ring', 'Leather', 'Textile',
    'Money', 'Receipt', 'Toy', 'Stuffed toy', 'Plush', 'Lego',
  ],
  'Gastronomie': [
    'Food', 'Cuisine', 'Meal', 'Lunch', 'Supper', 'Eating', 'Fast food',
    'Cheeseburger', 'Hot dog', 'Pizza', 'Sushi', 'Bento', 'Pho', 'Couscous',
    'Pasteles', 'Bread', 'Cake', 'Pie', 'Cookie', 'Icing', 'Gelato', 'Fruit',
    'Vegetable', 'Juice', 'Coffee', 'Cappuccino', 'Cola', 'Wine', 'Alcohol',
    'Bar', 'Menu', 'Cutlery', 'Tableware', 'Cup', 'Cookware and bakeware',
    'Kitchen', 'Steaming',
  ],
  'Culture': [
    'Museum', 'Monument', 'Statue', 'Ruins', 'Palace', 'Castle', 'Tower',
    'Church', 'Cathedral', 'Mosque', 'Temple', 'Porcelain', 'Watercolor paint',
    'Poster', 'Comics', 'Concert', 'Musical', 'Musical instrument', 'Piano',
    'Musician', 'Singer', 'Song', 'Pop music', 'Deejay', 'Dance', 'Carnival',
    'Circus',
  ],
  'Nature': [
    'Mountain', 'Forest', 'Jungle', 'Lake', 'River', 'Waterfall', 'Beach',
    'Cliff', 'Canyon', 'Cave', 'Caving', 'Glacier', 'Iceberg', 'Volcano',
    'Desert', 'Dune', 'Prairie', 'Field', 'Swamp', 'Reef', 'Underwater',
    'Sunset', 'Aurora', 'Sky', 'Rock', 'Park', 'Garden', 'Flower', 'Flora',
    'Plant', 'Bird', 'Horse', 'Safari', 'Camping', 'Backpacking',
  ],
};

/// Catégorie de la première étiquette reconnue (les plus probables en premier),
/// « Autre » si aucune ne correspond.
String categoryFor(Iterable<String> labels) {
  for (final label in labels) {
    for (final entry in _labelsByCategory.entries) {
      if (entry.value.contains(label)) return entry.key;
    }
  }
  return 'Autre';
}

/// Devine la catégorie d'une image avec ML Kit Image Labeling (modèle embarqué,
/// exécuté sur le téléphone, sans connexion ni clé d'API).
Future<String> classifyImage(String path) async {
  // shortcut: ML Kit n'existe que sur Android/iOS ; sur le web la catégorie reste « Autre ».
  if (kIsWeb) return 'Autre';

  final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
  try {
    final labels = List.of(await labeler.processImage(InputImage.fromFilePath(path)));
    labels.sort((a, b) => b.confidence.compareTo(a.confidence));
    debugPrint('ML Kit : ${labels.map((l) => '${l.label} ${l.confidence.toStringAsFixed(2)}').join(', ')}');
    return categoryFor(labels.map((l) => l.label));
  } finally {
    await labeler.close();
  }
}
