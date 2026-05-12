class Property {
  Property({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.rating,
    required this.distanceKm,
    required this.verified,
    required this.prices,
    required this.nextStarts,
  });

  final String id;
  final String name;
  final String imageAsset;
  final double rating;
  final double distanceKm;
  final bool verified;
  final Map<String, double> prices;
  final List<String> nextStarts;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageAsset': imageAsset,
        'rating': rating,
        'distanceKm': distanceKm,
        'verified': verified,
        'prices': prices,
        'nextStarts': nextStarts,
      };

  static List<Map<String, dynamic>> seed() => [
        Property(
          id: 'p1',
          name: 'Homestay Thachi',
          imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
          rating: 4.6,
          distanceKm: 0.8,
          verified: true,
          prices: {'30m': 99.0, '1h': 149.0, '2h': 249.0, '3h': 329.0, '4h': 389.0},
          nextStarts: const ['11:00', '11:30', '12:00', '12:30'],
        ).toJson(),
        Property(
          id: 'p2',
          name: 'Village Room, Jibhi',
          imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/puffin.jpg',
          rating: 4.4,
          distanceKm: 1.2,
          verified: true,
          prices: {'30m': 89.0, '1h': 139.0, '2h': 229.0, '3h': 309.0, '4h': 369.0},
          nextStarts: const ['10:30', '11:00', '11:30'],
        ).toJson(),
        Property(
          id: 'p3',
          name: 'Bir Hill Pod',
          imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/flamingos.jpg',
          rating: 4.5,
          distanceKm: 2.7,
          verified: false,
          prices: {'30m': 79.0, '1h': 129.0, '2h': 219.0, '3h': 289.0, '4h': 349.0},
          nextStarts: const ['12:00', '12:30', '13:00'],
        ).toJson(),
      ];
}
