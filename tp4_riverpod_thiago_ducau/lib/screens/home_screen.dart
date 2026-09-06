import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/place_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  final String? username;

  const HomeScreen({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares turísticos'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final p = places[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Image.network(p.imageUrl, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
              title: Text(p.name),
              subtitle: Text('${p.location} • ${p.rating.toStringAsFixed(1)} ⭐'),
              onTap: () => context.go('/detail', extra: p.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    final locationController = TextEditingController();
    final ratingController = TextEditingController();
    // Nuevos controladores
    final foodsController = TextEditingController();
    final spotsController = TextEditingController();
    final tipsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar nuevo destino', style: TextStyle(color: Colors.indigo)),
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
              ref.read(placeListProvider.notifier).addPlace(
                name: nameController.text.trim(),
                description: descController.text.trim(),
                imageUrl: imageController.text.trim(),
                location: locationController.text.trim(),
                rating: double.parse(ratingController.text.trim()),
                recommendedFoods: foodsController.text.trim(),
                touristSpots: spotsController.text.trim(),
                recommendations: tipsController.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Agregar destino'),
          ),
        ],
      ),
    );
  }
}