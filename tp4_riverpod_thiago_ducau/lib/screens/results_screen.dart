import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ResultsScreen extends ConsumerWidget {
  final Map<String, dynamic> results;

  const ResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Función auxiliar actualizada al nuevo estilo
    Widget buildResultCard(String title, String name, String description, IconData icon) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.withOpacity(0.1),
            child: Icon(icon, color: Colors.indigo),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Nombre: $name',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Descripción: $description',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo coherente
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: Colors.indigo, // Mismo color de AppBar
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildResultCard(
            'Producto más caro',
            results['mostExpensiveName'] ?? 'N/A',
            results['mostExpensiveDescription'] ?? 'N/A',
            Icons.trending_up, // Ícono representativo
          ),
          buildResultCard(
            'Producto más barato',
            results['cheapestName'] ?? 'N/A',
            results['cheapestDescription'] ?? 'N/A',
            Icons.trending_down,
          ),
          buildResultCard(
            'Mayor cantidad',
            results['highestQuantityName'] ?? 'N/A',
            results['highestQuantityDescription'] ?? 'N/A',
            Icons.inventory_2_outlined,
          ),
          buildResultCard(
            'Menor cantidad',
            results['lowestQuantityName'] ?? 'N/A',
            results['lowestQuantityDescription'] ?? 'N/A',
            Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 8),
          // Tarjeta de total destacada en índigo
          Card(
            elevation: 3,
            color: Colors.indigo, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Precio promedio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '\$${(results['averagePrice'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent, // Resalta sobre el fondo índigo
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}