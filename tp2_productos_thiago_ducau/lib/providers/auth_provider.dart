import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../entities/user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<User?> {
  final List<User> _registered = [];
  final _uuid = const Uuid();

  AuthNotifier() : super(null);

  String? register({required String name, required String email, required String password, required String confirmPassword}) {
    if (name.isEmpty || email.isEmpty || password.isEmpty) return 'Todos los campos son obligatorios';
    if (password != confirmPassword) return 'Las contraseñas no coinciden';
    if (_registered.any((u) => u.email == email)) return 'Email ya registrado';

    final user = User(id: _uuid.v4(), name: name, email: email, password: password);
    _registered.add(user);
    state = user;
    return null;
  }

  String? login({required String email, required String password}) {
    try {
      final found = _registered.firstWhere((u) => u.email == email && u.password == password);
      state = found;
    } catch (_) {
      return 'Usuario o contraseña incorrectos';
    }
    return null;
  }

  void logout() {
    state = null;
  }
}
