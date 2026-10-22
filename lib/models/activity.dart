/// Une activité à laquelle on peut s'inscrire (collection `activities`,
/// recopiée telle quelle dans le panier de l'utilisateur).
class Activity {
  const Activity({
    this.id = '',
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    required this.maxPeople,
    required this.image,
  });

  factory Activity.fromMap(String id, Map<String, dynamic> data) => Activity(
        id: id,
        title: data['title'] as String? ?? '',
        category: data['category'] as String? ?? '',
        location: data['location'] as String? ?? '',
        price: (data['price'] as num?)?.toInt() ?? 0,
        maxPeople: (data['maxPeople'] as num?)?.toInt() ?? 0,
        image: data['image'] as String? ?? '',
      );

  final String id;
  final String title;
  final String category;
  final String location;

  /// Prix en euros (entier : le formulaire n'accepte que des chiffres).
  final int price;
  final int maxPeople;

  /// URL http(s) pour les données de démo, ou image encodée en base64
  /// pour les activités ajoutées depuis l'application.
  final String image;

  String get priceLabel => '$price €';

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'location': location,
        'price': price,
        'maxPeople': maxPeople,
        'image': image,
      };
}
