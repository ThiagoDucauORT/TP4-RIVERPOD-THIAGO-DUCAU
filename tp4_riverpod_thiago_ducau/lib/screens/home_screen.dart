import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/place.dart';
import '../providers/auth_provider.dart';
import '../providers/place_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placeListProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Lugares turísticos'), actions: [
        if (user?.displayName?.isNotEmpty == true)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Center(child: Text(user!.displayName!))),
        IconButton(tooltip: 'Cerrar sesión', icon: const Icon(Icons.logout), onPressed: () async {
          try { await ref.read(authProvider).logout(); if (context.mounted) context.go('/'); }
          on FirebaseAuthException catch (e) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error al cerrar sesión.')));
          }
        }),
      ]),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 48), const SizedBox(height: 12),
            Text('No se pudieron cargar los destinos: $e', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => ref.invalidate(placeListProvider), child: const Text('Reintentar')),
          ],
        ))),
        data: (places) => places.isEmpty
          ? const Center(child: Text('Todavía no agregaste destinos. Tocá + para crear el primero.'))
          : ListView.builder(padding: const EdgeInsets.all(12), itemCount: places.length,
              itemBuilder: (context, index) => _placeCard(context, places[index])),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context, ref), icon: const Icon(Icons.add), label: const Text('Agregar destino')),
    );
  }

  Widget _placeCard(BuildContext context, Place p) => Card(
    clipBehavior: Clip.antiAlias, margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.all(10),
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 76, height: 76,
        child: p.imageUrl.isEmpty ? const Icon(Icons.image_not_supported) : Image.network(p.imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)))),
      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${p.location} • ${p.rating.toStringAsFixed(1)} ⭐'),
      trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/detail/${p.id}'),
    ),
  );

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    final data = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => const _PlaceFormDialog());
    if (data == null || !context.mounted) return;
    try {
      await ref.read(placeRepositoryProvider).addPlace(
        name: data['name'], description: data['description'], imageUrl: data['imageUrl'],
        location: data['location'], rating: data['rating'], recommendedFoods: data['recommendedFoods'],
        touristSpots: data['touristSpots'], recommendations: data['recommendations']);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    }
  }
}

class _PlaceFormDialog extends StatefulWidget {
  const _PlaceFormDialog();
  @override
  State<_PlaceFormDialog> createState() => _PlaceFormDialogState();
}
class _PlaceFormDialogState extends State<_PlaceFormDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController(), _description = TextEditingController(), _image = TextEditingController(),
    _location = TextEditingController(), _rating = TextEditingController(), _foods = TextEditingController(),
    _spots = TextEditingController(), _tips = TextEditingController();

  @override
  void dispose() { for (final c in [_name,_description,_image,_location,_rating,_foods,_spots,_tips]) { c.dispose(); } super.dispose(); }

  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Campo obligatorio.' : null;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Agregar destino'),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Form(key: _key, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _field(_name, 'Nombre', _required), _field(_location, 'País / ubicación', _required),
      _field(_image, 'URL de imagen', (v) { final err = _required(v); if (err != null) return err; final u = Uri.tryParse(v!.trim()); return u == null || !['http','https'].contains(u.scheme) ? 'URL http/https inválida.' : null; }),
      _field(_rating, 'Valoración (0 a 5)', (v) { final n = double.tryParse(v ?? ''); return n == null || n < 0 || n > 5 ? 'Ingresá un valor entre 0 y 5.' : null; }, keyboard: TextInputType.number),
      _field(_description, 'Descripción', _required, maxLines: 3), _field(_spots, 'Lugares imperdibles', _required, maxLines: 3),
      _field(_foods, 'Comidas típicas', _required, maxLines: 3), _field(_tips, 'Recomendaciones', _required, maxLines: 3),
    ])))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: () { if (!_key.currentState!.validate()) return; Navigator.pop(context, {
        'name':_name.text, 'description':_description.text, 'imageUrl':_image.text, 'location':_location.text,
        'rating':double.parse(_rating.text), 'recommendedFoods':_foods.text, 'touristSpots':_spots.text, 'recommendations':_tips.text,
      }); }, child: const Text('Guardar')),
    ],
  );

  Widget _field(TextEditingController c, String label, String? Function(String?) validator, {int maxLines = 1, TextInputType? keyboard}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, maxLines: maxLines, keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: validator));
}
