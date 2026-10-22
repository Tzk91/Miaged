import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'web_classifier_stub.dart'
    if (dart.library.js_interop) 'web_classifier_web.dart';

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

/// Version web (MobileNet) : mots des classes ImageNet qui mènent à chaque catégorie.
/// Une classe ImageNet est une liste de synonymes (« frying pan, frypan, skillet ») :
/// on compare mot à mot, pour que « skillet » ne soit pas pris pour « ski ».
/// L'ordre compte : « punching bag » relève du Sport avant le Shopping.
const _imageNetKeywords = {
  'Sport': {
    'canoe',
    'paddle',
    'scuba',
    'snorkel',
    'ski',
    'ballplayer',
    'volleyball',
    'basketball',
    'soccer',
    'rugby',
    'football',
    'tennis',
    'golf',
    'racket',
    'puck',
    'baseball',
    'croquet',
    'ping',
    'dumbbell',
    'barbell',
    'punching',
    'bicycle',
    'bike',
    'unicycle',
    'helmet',
    'bars',
    'beam',
    'swimming',
    'kart',
    'bobsled',
    'snowmobile',
  },
  'Shopping': {
    'shop',
    'store',
    'toyshop',
    'bookshop',
    'barbershop',
    'boutique',
    'market',
    'basket',
    'cart',
    'bag',
    'purse',
    'wallet',
    'backpack',
    'sunglasses',
    'jean',
    'miniskirt',
    'cardigan',
    'suit',
    'shoe',
    'loafer',
    'sandal',
    'boot',
    'necklace',
    'lipstick',
    'perfume',
  },
  'Gastronomie': {
    'food',
    'restaurant',
    'bakery',
    'menu',
    'plate',
    'dining',
    'pizza',
    'dough',
    'bagel',
    'pretzel',
    'loaf',
    'burrito',
    'hotdog',
    'cheeseburger',
    'guacamole',
    'carbonara',
    'consomme',
    'trifle',
    'potpie',
    'cream',
    'espresso',
    'coffee',
    'cup',
    'teapot',
    'wine',
    'beer',
    'eggnog',
    'skillet',
    'frypan',
    'wok',
    'caldron',
    'waffle',
    'hotpot',
    'soup',
    'potato',
    'broccoli',
    'cauliflower',
    'zucchini',
    'cucumber',
    'mushroom',
    'strawberry',
    'orange',
    'lemon',
    'banana',
    'pineapple',
    'pomegranate',
    'fig',
    'chocolate',
    'confectionery',
    'butcher',
  },
  'Culture': {
    'palace',
    'monastery',
    'church',
    'mosque',
    'castle',
    'library',
    'cinema',
    'theater',
    'triumphal',
    'obelisk',
    'stupa',
    'dome',
    'altar',
    'organ',
    'piano',
    'violin',
    'cello',
    'guitar',
    'drum',
    'accordion',
    'harp',
    'trombone',
    'cornet',
    'sax',
    'banjo',
    'flute',
    'oboe',
    'harmonica',
    'book',
    'comic',
    'totem',
    'planetarium',
  },
  'Nature': {
    'lakeside',
    'valley',
    'alp',
    'cliff',
    'volcano',
    'seashore',
    'coast',
    'coral',
    'reef',
    'geyser',
    'promontory',
    'sandbar',
    'mountain',
    'daisy',
  },
};

String? _imageNetCategory(String className) {
  final words = className.toLowerCase().split(RegExp('[^a-z]+')).toSet();
  for (final entry in _imageNetKeywords.entries) {
    if (entry.value.any(words.contains)) return entry.key;
  }
  return null;
}

/// Catégorie d'après les étiquettes ML Kit (Android/iOS).
String categoryFor(List<(String, double)> labels) =>
    _bestCategory(labels, (label) => _categoryOfLabel[label]);

/// Catégorie d'après les classes ImageNet de MobileNet (web).
String categoryForImageNet(List<(String, double)> labels) =>
    _bestCategory(labels, _imageNetCategory);

/// Choisit la catégorie dont les étiquettes reconnues cumulent la plus forte confiance,
/// « Autre » si aucune étiquette ne correspond à une catégorie.
///
/// Additionner les confiances rend le choix plus robuste qu'une seule étiquette :
/// une photo de repas reconnue « Food », « Cuisine » et « Tableware » l'emporte
/// sur un « Statue » isolé en arrière-plan.
String _bestCategory(
  List<(String, double)> labels,
  String? Function(String label) categoryOf,
) {
  final scores = <String, double>{};
  for (final (label, confidence) in labels) {
    final category = categoryOf(label);
    if (category != null) {
      scores[category] = (scores[category] ?? 0) + confidence;
    }
  }
  if (scores.isEmpty) return 'Autre';
  return scores.entries
      .reduce((best, entry) => entry.value > best.value ? entry : best)
      .key;
}

/// Analyse une image et en déduit sa catégorie :
/// ML Kit sur Android/iOS (modèle embarqué, sans connexion ni clé d'API),
/// MobileNet via TensorFlow.js dans le navigateur.
/// Les étiquettes reconnues sont écrites dans la console.
Future<String> classifyImage(String path, Uint8List bytes) =>
    kIsWeb ? _classifyWithMobileNet(bytes) : _classifyWithMlKit(path);

Future<String> _classifyWithMobileNet(Uint8List bytes) async {
  // Les classes très peu probables (< 5 %) ne sont que du bruit.
  final predictions = [
    for (final prediction in await classifyOnWeb(bytes))
      if (prediction.$2 >= 0.05) prediction,
  ];
  final category = categoryForImageNet(predictions);
  debugPrint(
    'MobileNet : ${predictions.map((p) => '${p.$1} ${p.$2.toStringAsFixed(2)}').join(' | ')}'
    ' → $category',
  );
  return category;
}

Future<String> _classifyWithMlKit(String path) async {
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
    return category;
  } finally {
    await labeler.close();
  }
}
