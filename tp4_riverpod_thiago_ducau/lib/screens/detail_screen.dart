import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(placeListProvider).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(title: const Text('Detalle')), body: Center(child: Text('Error: $e'))),
      data: (items) {
        Place? p;
        for (final item in items) { if (item.id == id) { p = item; break; } }
        if (p == null) return Scaffold(appBar: AppBar(title: const Text('Detalle')), body: const Center(child: Text('Lugar no encontrado.')));
        final place = p!;
        return Scaffold(body: CustomScrollView(slivers: [
          SliverAppBar(expandedHeight: 280, pinned: true, actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(context, ref, place)),
            IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(context, ref, place)),
          ], flexibleSpace: FlexibleSpaceBar(title: Text(place.name),
            background: place.imageUrl.isEmpty ? const ColoredBox(color: Colors.indigo) : Image.network(place.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.indigo, child: Icon(Icons.image, size: 70))))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.location_on, color: Colors.indigo), const SizedBox(width: 6),
              Expanded(child: Text(place.location, style: Theme.of(context).textTheme.titleMedium)),
              Chip(avatar: const Icon(Icons.star, size: 18), label: Text(place.rating.toStringAsFixed(1)))]),
            const SizedBox(height: 18),
            _section('Descripción', Icons.info_outline, place.description),
            _section('Lugares imperdibles', Icons.camera_alt_outlined, place.touristSpots),
            _section('Comidas típicas', Icons.restaurant_menu, place.recommendedFoods),
            _section('Recomendaciones', Icons.lightbulb_outline, place.recommendations),
          ]))),
        ]));
      },
    );
  }

  Widget _section(String title, IconData icon, String content) => Card(margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: Colors.indigo), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))]),
      const Divider(), Text(content),
    ])));

  Future<void> _delete(BuildContext context, WidgetRef ref, Place p) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Eliminar destino'), content: Text('¿Querés eliminar "${p.name}"?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar'))]));
    if (confirm != true || !context.mounted) return;
    try {
      await ref.read(placeRepositoryProvider).deletePlace(p.id);
      if (context.mounted) context.go('/home');
    } on FirebaseException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: ${e.message}')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Place p) async {
    final edited = await showDialog<Place>(context: context, builder: (_) => _EditPlaceDialog(place: p));
    if (edited == null || !context.mounted) return;
    try {
      await ref.read(placeRepositoryProvider).updatePlace(edited);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Destino actualizado.')));
    } on FirebaseException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar: ${e.message}')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar: $e')));
    }
  }
}

class _EditPlaceDialog extends StatefulWidget {
  const _EditPlaceDialog({required this.place});
  final Place place;
  @override
  State<_EditPlaceDialog> createState() => _EditPlaceDialogState();
}
class _EditPlaceDialogState extends State<_EditPlaceDialog> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.place.name);
  late final _description = TextEditingController(text: widget.place.description);
  late final _image = TextEditingController(text: widget.place.imageUrl);
  late final _location = TextEditingController(text: widget.place.location);
  late final _rating = TextEditingController(text: widget.place.rating.toString());
  late final _foods = TextEditingController(text: widget.place.recommendedFoods);
  late final _spots = TextEditingController(text: widget.place.touristSpots);
  late final _tips = TextEditingController(text: widget.place.recommendations);

  @override
  void dispose() { for (final c in [_name,_description,_image,_location,_rating,_foods,_spots,_tips]) { c.dispose(); } super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Editar destino'),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Form(key: _key, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _field(_name, 'Nombre'), _field(_location, 'País / ubicación'),
      _field(_image, 'URL de imagen', validator: (v) { final u = Uri.tryParse(v ?? ''); return u == null || !['http','https'].contains(u.scheme) ? 'URL http/https inválida.' : null; }),
      _field(_rating, 'Valoración (0 a 5)', keyboard: TextInputType.number, validator: (v) { final n = double.tryParse(v ?? ''); return n == null || n < 0 || n > 5 ? 'Ingresá un valor entre 0 y 5.' : null; }),
      _field(_description, 'Descripción', maxLines: 3), _field(_spots, 'Lugares imperdibles', maxLines: 3),
      _field(_foods, 'Comidas típicas', maxLines: 3), _field(_tips, 'Recomendaciones', maxLines: 3),
    ])))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: () { if (!_key.currentState!.validate()) return; Navigator.pop(context, widget.place.copyWith(
        name: _name.text.trim(), description: _description.text.trim(), imageUrl: _image.text.trim(),
        location: _location.text.trim(), rating: double.parse(_rating.text), recommendedFoods: _foods.text.trim(),
        touristSpots: _spots.text.trim(), recommendations: _tips.text.trim())); }, child: const Text('Guardar cambios')),
    ],
  );

  Widget _field(TextEditingController c, String label, {int maxLines = 1, TextInputType? keyboard, String? Function(String?)? validator}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, maxLines: maxLines, keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio.' : validator?.call(v)));
}
