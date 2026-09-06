class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String location; 
  final double rating; 
  final String recommendedFoods;
  final String touristSpots;
  final String recommendations;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.recommendedFoods,
    required this.touristSpots,
    required this.recommendations,
  });

  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    double? rating,
    String? recommendedFoods,
    String? touristSpots,
    String? recommendations,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      recommendedFoods: recommendedFoods ?? this.recommendedFoods,
      touristSpots: touristSpots ?? this.touristSpots,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}