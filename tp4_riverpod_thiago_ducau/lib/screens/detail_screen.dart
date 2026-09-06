import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/place_provider.dart';
import '../models/place.dart';

class DetailScreen extends ConsumerWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Place? place;
    try {
      place = ref.watch(placeListProvider).firstWhere((p) => p.id == id);
    } catch (_) {
      place = null;
    }

    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Lugar no encontrado')),
      );
    }
    final p = place;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Cabecera dinámica con imagen
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _openEditDialog(context, ref, p),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Confirmar'),
                      content: const Text('¿Eliminar este lugar definitivamente?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancelar')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          onPressed: () => Navigator.of(c).pop(true), 
                          child: const Text('Eliminar')
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    ref.read(placeListProvider.notifier).deletePlace(p.id);
                    context.go('/home');
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                p.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 100)),
                  // Gradiente oscuro para que el texto resalte
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido de la pantalla
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ubicación y Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.indigo, size: 24),
                          const SizedBox(width: 8),
                          Text(p.location, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(p.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Secciones de información
                  _buildSectionCard(title: 'Acerca de', icon: Icons.info_outline, content: p.description),
                  _buildSectionCard(title: 'Lugares Imperdibles', icon: Icons.camera_alt_outlined, content: p.touristSpots),
                  _buildSectionCard(title: 'Comidas Típicas', icon: Icons.restaurant_menu, content: p.recommendedFoods),
                  _buildSectionCard(title: 'Recomendaciones', icon: Icons.lightbulb_outline, content: p.recommendations),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para las tarjetas de información
  Widget _buildSectionCard({required String title, required IconData icon, required String content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo, size: 22),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, WidgetRef ref, Place place) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: place.name);
    final descController = TextEditingController(text: place.description);
    final imageController = TextEditingController(text: place.imageUrl);
    final locationController = TextEditingController(text: place.location);
    final ratingController = TextEditingController(text: place.rating.toString());
    // Nuevos controladores
    final foodsController = TextEditingController(text: place.recommendedFoods);
    final spotsController = TextEditingController(text: place.touristSpots);
    final tipsController = TextEditingController(text: place.recommendations);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar lugar', style: TextStyle(color: Colors.indigo)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                  TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Ubicación (País)'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                  TextFormField(controller: imageController, decoration: const InputDecoration(labelText: 'URL imagen'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                  TextFormField(controller: ratingController, decoration: const InputDecoration(labelText: 'Rating (0-5)'), keyboardType: TextInputType.number, validator: (v) {
                    if (v==null||v.isEmpty) return 'Requerido';
                    final val = double.tryParse(v);
                    if (val==null || val<0 || val>5) return 'Valor entre 0 y 5';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  TextFormField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción detallada', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 3, validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                  const SizedBox(height: 12),
                  TextFormField(controller: spotsController, decoration: const InputDecoration(labelText: 'Lugares para visitar', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 3, validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                  const SizedBox(height: 12),
                  TextFormField(controller: foodsController, decoration: const InputDecoration(labelText: 'Comidas típicas', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 3, validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                  const SizedBox(height: 12),
                  TextFormField(controller: tipsController, decoration: const InputDecoration(labelText: 'Recomendaciones', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 3, validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final updated = place.copyWith(
                name: nameController.text.trim(),
                description: descController.text.trim(),
                imageUrl: imageController.text.trim(),
                location: locationController.text.trim(),
                rating: double.parse(ratingController.text.trim()),
                recommendedFoods: foodsController.text.trim(),
                touristSpots: spotsController.text.trim(),
                recommendations: tipsController.text.trim(),
              );
              ref.read(placeListProvider.notifier).updatePlace(updated);
              Navigator.of(context).pop();
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}