import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false, _obscure = true;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider).login(email: _email.text.trim(), password: _password.text);
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'Email o contraseña incorrectos.',
        'invalid-email' => 'El email no tiene un formato válido.',
        'too-many-requests' => 'Demasiados intentos. Probá más tarde.',
        _ => e.message ?? 'No se pudo iniciar sesión.',
      };
      _show(message);
    } catch (_) { _show('No se pudo iniciar sesión. Revisá tu conexión.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _show(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Iniciar sesión')),
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Card(child: Padding(
        padding: const EdgeInsets.all(24), child: Form(key: _key, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.travel_explore, size: 56, color: Colors.indigo),
            const SizedBox(height: 16),
            Text('Bienvenido', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Ingresá tu email.';
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value) ? null : 'Email inválido.';
              }),
            const SizedBox(height: 16),
            TextFormField(controller: _password, obscureText: _obscure,
              decoration: InputDecoration(labelText: 'Contraseña', border: const OutlineInputBorder(),
                suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off))),
              validator: (v) => v == null || v.isEmpty ? 'Ingresá tu contraseña.' : null),
            const SizedBox(height: 24),
            FilledButton(onPressed: _busy ? null : _login, child: _busy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Ingresar')),
            TextButton(onPressed: () => context.go('/register'), child: const Text('Crear cuenta')),
          ],
        )),
      ))),
    )),
  );
}
