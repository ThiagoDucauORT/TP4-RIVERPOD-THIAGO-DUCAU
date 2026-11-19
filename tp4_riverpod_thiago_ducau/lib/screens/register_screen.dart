import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(),
    _password = TextEditingController(), _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose();
  }

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider).register(name: _name.text.trim(), email: _email.text.trim(), password: _password.text);
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'Ese email ya está registrado.',
        'invalid-email' => 'El email no tiene un formato válido.',
        'weak-password' => 'La contraseña es demasiado débil (mínimo 6 caracteres).',
        'operation-not-allowed' => 'Habilitá Email/Password en Firebase Authentication.',
        _ => e.message ?? 'No se pudo crear la cuenta.',
      };
      _show(message);
    } catch (_) { _show('No se pudo crear la cuenta. Revisá tu conexión.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _show(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Crear cuenta')),
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Card(child: Padding(
        padding: const EdgeInsets.all(24), child: Form(key: _key, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresá tu nombre.' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Ingresá tu email.';
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value) ? null : 'Email inválido.';
              }),
            const SizedBox(height: 12),
            TextFormField(controller: _password, obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              validator: (v) => v == null || v.length < 6 ? 'Usá al menos 6 caracteres.' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _confirm, obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar contraseña', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Confirmá la contraseña.' : v != _password.text ? 'Las contraseñas no coinciden.' : null),
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _register, child: _busy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Registrarme')),
          ],
        )),
      ))),
    )),
  );
}
