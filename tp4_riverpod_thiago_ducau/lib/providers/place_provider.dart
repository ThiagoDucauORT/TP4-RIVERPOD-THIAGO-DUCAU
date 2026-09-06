import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';

final placeListProvider = StateNotifierProvider<PlaceListNotifier, List<Place>>((ref) {
  return PlaceListNotifier();
});

class PlaceListNotifier extends StateNotifier<List<Place>> {
  final _uuid = const Uuid();

  PlaceListNotifier() : super(_initialPlaces);

  static final List<Place> _initialPlaces = [
    Place(
      id: const Uuid().v4(),
      name: 'Buenos Aires',
      description: 'La vibrante capital de Argentina combina la elegancia europea con la pasión latinoamericana. Es mundialmente conocida por ser la cuna del tango, su arquitectura deslumbrante que recuerda a París o Madrid, y una vida nocturna que literalmente nunca se apaga. Sus barrios, desde el colorido Caminito hasta el moderno Puerto Madero, ofrecen contrastes fascinantes.',
      imageUrl: 'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?q=80&w=800&auto=format&fit=crop',
      location: 'Argentina',
      rating: 4.8,
      recommendedFoods: '• Asado tradicional argentino\n• Empanadas de carne cortada a cuchillo\n• Choripán con chimichurri\n• Alfajores de maicena con dulce de leche\n• Milanesa a la napolitana',
      touristSpots: '• Obelisco y Avenida 9 de Julio\n• Teatro Colón (uno de los mejores del mundo)\n• Caminito en La Boca\n• Cementerio de la Recoleta\n• Bosques de Palermo',
      recommendations: 'Usa la tarjeta SUBE para moverte en transporte público. Es seguro caminar de día por zonas turísticas, pero mantén tus pertenencias a la vista en aglomeraciones. No te vayas sin ir a una "Milonga" a ver bailar tango.',
    ),
    Place(
      id: const Uuid().v4(),
      name: 'Nueva York',
      description: 'Conocida como la "Capital del Mundo", Nueva York es el epicentro global del arte, la moda, la gastronomía y el teatro. Cada uno de sus cinco distritos tiene una personalidad única. Es una ciudad hiperactiva donde los rascacielos imponentes se mezclan con inmensos parques urbanos.',
      imageUrl: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?q=80&w=800&auto=format&fit=crop',
      location: 'Estados Unidos',
      rating: 4.9,
      recommendedFoods: '• Pizza estilo New York (porciones gigantes)\n• Bagels con queso crema y salmón\n• Hot dogs de carritos callejeros\n• Cheesecake neoyorquino\n• Hamburguesas artesanales',
      touristSpots: '• Times Square y Broadway\n• Central Park\n• Estatua de la Libertad e Isla Ellis\n• Empire State Building y Top of the Rock\n• Puente de Brooklyn',
      recommendations: 'Camina todo lo que puedas, es la mejor forma de conocer la ciudad. El metro funciona 24/7 y es la forma más rápida de moverse. Compra las entradas a los miradores con antelación por internet.',
    ),
    Place(
      id: const Uuid().v4(),
      name: 'Roma',
      description: 'La "Ciudad Eterna" es un espectacular museo al aire libre. Con casi 3.000 años de arte, arquitectura y cultura de influencia mundial a la vista de todos. Pasear por sus calles adoquinadas es viajar en el tiempo, desde el Imperio Romano hasta el Renacimiento.',
      imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?q=80&w=800&auto=format&fit=crop',
      location: 'Italia',
      rating: 4.9,
      recommendedFoods: '• Pasta Carbonara (la auténtica, sin crema)\n• Pizza Romana (masa fina y crujiente)\n• Gelato artesanal\n• Tiramisú\n• Supplí (croquetas de arroz y queso)',
      touristSpots: '• El Coliseo y el Foro Romano\n• La Fontana di Trevi\n• El Panteón de Agripa\n• Ciudad del Vaticano (Basílica de San Pedro y Museos)\n• Plaza Navona',
      recommendations: 'Lleva calzado muy cómodo porque las calles son de adoquines antiguos. Hay fuentes de agua potable (Nasoni) por toda la ciudad, lleva una botella reutilizable. Lanza una moneda a la Fontana di Trevi para asegurar tu regreso.',
    ),
    Place(
      id: const Uuid().v4(),
      name: 'Río de Janeiro',
      description: 'Famosa por sus hermosas playas como Copacabana e Ipanema, y el icónico Cristo Redentor sobre el cerro del Corcovado. Una ciudad llena de ritmo, color, samba y un entorno natural espectacular donde la selva tropical se encuentra con el mar.',
      imageUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?q=80&w=800&auto=format&fit=crop',
      location: 'Brasil',
      rating: 4.7,
      recommendedFoods: '• Feijoada tradicional\n• Pão de queijo (Pan de queso)\n• Caipirinha\n• Açaí na tigela\n• Churrasco brasileño (Rodizio)',
      touristSpots: '• Cristo Redentor (Corcovado)\n• Pan de Azúcar (Pão de Açúcar)\n• Playas de Copacabana e Ipanema\n• Escalinata de Selarón\n• Estadio Maracaná',
      recommendations: 'Usa protector solar y ropa ligera. Mantén tus objetos de valor seguros y evita ir a la playa con el celular de noche. No te pierdas el atardecer en la piedra de Arpoador.',
    ),
    Place(
      id: const Uuid().v4(),
      name: 'Londres',
      description: 'Capital del Reino Unido, con una historia fascinante. Es una metrópolis cosmopolita que combina a la perfección la realeza y la tradición con la vanguardia cultural, musical y arquitectónica. Sus icónicos autobuses rojos y cabinas telefónicas la hacen inconfundible.',
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-5969336ac521?q=80&w=800&auto=format&fit=crop',
      location: 'Reino Unido',
      rating: 4.8,
      recommendedFoods: '• Fish and Chips (Pescado frito con papas)\n• English Breakfast (Desayuno inglés completo)\n• Sunday Roast con Yorkshire pudding\n• Té de la tarde con scones y crema\n• Pie and mash (Pastel de carne con puré)',
      touristSpots: '• Big Ben y el Palacio de Westminster\n• El London Eye\n• Torre de Londres y Tower Bridge\n• Palacio de Buckingham\n• Museo Británico (entrada gratuita)',
      recommendations: 'Consigue una tarjeta Oyster o usa tu tarjeta contactless para el transporte público. Lleva siempre un paraguas o impermeable, el clima puede ser impredecible. ¡Recuerda mirar a la derecha al cruzar la calle!',
    ),
    Place(
      id: const Uuid().v4(),
      name: 'París',
      description: 'La "Ciudad de la Luz". Reconocida mundialmente por su arte, su exquisita gastronomía, la moda y su innegable ambiente romántico. Sus pintorescos cafés a pie de calle y museos de clase mundial la hacen un destino que hay que visitar al menos una vez en la vida.',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e907611a509?q=80&w=800&auto=format&fit=crop',
      location: 'Francia',
      rating: 4.9,
      recommendedFoods: '• Croissants y pain au chocolat recién horneados\n• Crêpes (dulces y salados)\n• Macarons de colores\n• Sopa de cebolla francesa\n• Variedad de quesos locales y baguette',
      touristSpots: '• Torre Eiffel\n• Museo del Louvre\n• Catedral de Notre-Dame\n• Arco del Triunfo y Avenida de los Campos Elíseos\n• Barrio de Montmartre y basílica del Sacré-Cœur',
      recommendations: 'Aprende algunas frases básicas en francés ("Bonjour", "Merci"), los locales aprecian mucho el esfuerzo. Compra un pase de museos si planeas visitar varios para saltar filas. Ten cuidado con los carteristas en el metro.',
    ),
  ];

  void addPlace({
    required String name,
    required String description,
    required String imageUrl,
    required String location,
    required double rating,
    required String recommendedFoods,
    required String touristSpots,
    required String recommendations,
  }) {
    final newPlace = Place(
      id: _uuid.v4(),
      name: name,
      description: description,
      imageUrl: imageUrl,
      location: location,
      rating: rating,
      recommendedFoods: recommendedFoods,
      touristSpots: touristSpots,
      recommendations: recommendations,
    );
    state = [...state, newPlace];
  }

  void updatePlace(Place updatedPlace) {
    state = [
      for (final place in state)
        if (place.id == updatedPlace.id) updatedPlace else place
    ];
  }

  void deletePlace(String id) {
    state = state.where((place) => place.id != id).toList();
  }
}