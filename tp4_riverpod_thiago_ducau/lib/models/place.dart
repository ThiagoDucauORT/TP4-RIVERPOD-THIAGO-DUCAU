class Place {
  const Place({
    required this.id, required this.name, required this.description, required this.imageUrl,
    required this.location, required this.rating, required this.recommendedFoods,
    required this.touristSpots, required this.recommendations, required this.ownerId,
  });
  final String id, name, description, imageUrl, location, recommendedFoods, touristSpots, recommendations, ownerId;
  final double rating;

  factory Place.fromMap(String id, Map<String, dynamic> data) => Place(
    id: id,
    name: data['name'] as String? ?? '',
    description: data['description'] as String? ?? '',
    imageUrl: data['imageUrl'] as String? ?? '',
    location: data['location'] as String? ?? '',
    rating: (data['rating'] as num?)?.toDouble() ?? 0,
    recommendedFoods: data['recommendedFoods'] as String? ?? '',
    touristSpots: data['touristSpots'] as String? ?? '',
    recommendations: data['recommendations'] as String? ?? '',
    ownerId: data['ownerId'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'description': description, 'imageUrl': imageUrl, 'location': location,
    'rating': rating, 'recommendedFoods': recommendedFoods, 'touristSpots': touristSpots,
    'recommendations': recommendations, 'ownerId': ownerId,
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
  };

  Place copyWith({String? name, String? description, String? imageUrl, String? location,
    double? rating, String? recommendedFoods, String? touristSpots, String? recommendations}) => Place(
    id: id, name: name ?? this.name, description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl, location: location ?? this.location,
    rating: rating ?? this.rating, recommendedFoods: recommendedFoods ?? this.recommendedFoods,
    touristSpots: touristSpots ?? this.touristSpots, recommendations: recommendations ?? this.recommendations,
    ownerId: ownerId,
  );
}
