import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';

final placeListProvider = StateNotifierProvider<PlaceListNotifier, List<Place>>(
  (ref) => PlaceListNotifier(),
);

class PlaceListNotifier extends StateNotifier<List<Place>> {
  final _uuid = const Uuid();

  PlaceListNotifier()
      : super([
          // sample data
          Place(
            id: '1',
            name: 'Parque Nacional',
            description: 'Un hermoso parque con senderos y fauna.',
            imageUrl: 'https://picsum.photos/200/150?random=1',
            location: 'Provincia A',
            rating: 4.5,
          ),
          Place(
            id: '2',
            name: 'Playa Dorada',
            description: 'Arena fina y aguas transparentes.',
            imageUrl: 'https://picsum.photos/200/150?random=2',
            location: 'Provincia B',
            rating: 4.8,
          ),
        ]);

  void addPlace({required String name, required String description, required String imageUrl, required String location, required double rating}) {
    final p = Place(
      id: _uuid.v4(),
      name: name,
      description: description,
      imageUrl: imageUrl,
      location: location,
      rating: rating,
    );
    state = [...state, p];
  }

  void updatePlace(Place updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void deletePlace(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  Place? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
