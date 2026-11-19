import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final placeRepositoryProvider = Provider<PlaceRepository>((ref) =>
  PlaceRepository(ref.watch(firestoreProvider), fb.FirebaseAuth.instance));
final placeListProvider = StreamProvider<List<Place>>((ref) =>
  ref.watch(placeRepositoryProvider).watchPlaces());

class PlaceRepository {
  PlaceRepository(this._db, this._auth);
  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;
  CollectionReference<Map<String, dynamic>> get _collection => _db.collection('places');

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Debés iniciar sesión para continuar.');
    return user.uid;
  }

  Stream<List<Place>> watchPlaces() {
    final uid = _uid;
    return _collection.where('ownerId', isEqualTo: uid).snapshots().map((snapshot) {
      final places = snapshot.docs.map((doc) => Place.fromMap(doc.id, doc.data())).toList();
      places.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return places;
    });
  }

  Future<void> addPlace({
    required String name, required String description, required String imageUrl,
    required String location, required double rating, required String recommendedFoods,
    required String touristSpots, required String recommendations,
  }) async {
    final doc = _collection.doc();
    final place = Place(
      id: doc.id, name: name.trim(), description: description.trim(), imageUrl: imageUrl.trim(),
      location: location.trim(), rating: rating, recommendedFoods: recommendedFoods.trim(),
      touristSpots: touristSpots.trim(), recommendations: recommendations.trim(), ownerId: _uid,
    );
    await doc.set(place.toMap());
  }

  Future<void> updatePlace(Place place) async {
    if (place.ownerId != _uid) throw StateError('No tenés permisos para editar este lugar.');
    await _collection.doc(place.id).update(place.toMap());
  }

  Future<void> deletePlace(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data()?['ownerId'] != _uid) {
      throw StateError('No tenés permisos para eliminar este lugar.');
    }
    await doc.reference.delete();
  }
}
