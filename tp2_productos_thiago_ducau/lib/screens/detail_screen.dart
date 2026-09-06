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
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEditDialog(context, ref, p),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('Eliminar este lugar?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Eliminar')),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.network(p.imageUrl, height: 200, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.image, size: 100)),
          const SizedBox(height: 12),
          Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(p.location, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 8),
          Text('Rating: ${p.rating.toStringAsFixed(1)} ⭐', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(p.description),
        ],
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar lugar'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                TextFormField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                TextFormField(controller: imageController, decoration: const InputDecoration(labelText: 'URL imagen'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Ubicación'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
                TextFormField(controller: ratingController, decoration: const InputDecoration(labelText: 'Rating (0-5)'), keyboardType: TextInputType.number, validator: (v) {
                  if (v==null||v.isEmpty) return 'Requerido';
                  final val = double.tryParse(v);
                  if (val==null || val<0 || val>5) return 'Valor entre 0 y 5';
                  return null;
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final updated = place.copyWith(
                name: nameController.text.trim(),
                description: descController.text.trim(),
                imageUrl: imageController.text.trim(),
                location: locationController.text.trim(),
                rating: double.parse(ratingController.text.trim()),
              );
              ref.read(placeListProvider.notifier).updatePlace(updated);
              Navigator.of(context).pop();
              // refresh by popping and pushing detail again
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
