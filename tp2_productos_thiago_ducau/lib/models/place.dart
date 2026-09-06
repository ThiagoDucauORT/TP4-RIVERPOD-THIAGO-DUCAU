class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String location; // dato adicional
  final double rating; // dato adicional

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.rating,
  });

  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    double? rating,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      rating: rating ?? this.rating,
    );
  }
}
